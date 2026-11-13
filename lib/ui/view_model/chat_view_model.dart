import 'package:flutter/foundation.dart';

import '../../data/api_models/movie.dart';
import '../../data/repositories/movies_repository.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/genre_mapper.dart';
import '../../data/services/recommendation_context_service.dart';
import '../../utils/result.dart';
import 'chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required GeminiService geminiService,
    required MoviesRepository moviesRepository,
    required RecommendationContextService recommendationContextService,
  }) : _geminiService = geminiService,
       _moviesRepository = moviesRepository,
       _recommendationContextService = recommendationContextService;

  final GeminiService _geminiService;
  final MoviesRepository _moviesRepository;
  final RecommendationContextService _recommendationContextService;

  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String message) async {
    final text = message.trim();

    if (text.isEmpty || _isLoading) return;

    _messages.add(ChatMessage(text: text, role: ChatMessageRole.user));

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. A Gemini interpreta o pedido.
      final recommendationContext = await _recommendationContextService.build();

      final interpretation = await _geminiService.interpretPreferences(
        text,
        context: recommendationContext,
      );
      final explanation =
          interpretation['explanation'] as String? ??
          'Encontrei alguns critérios para sua busca.';

      final rawGenres = interpretation['genres'];

      final requestedGenres = rawGenres is List
          ? rawGenres.whereType<String>().toList()
          : <String>[];

      final preferredGenres = recommendationContext.favoriteGenres;
      final dislikedGenres = recommendationContext.dislikedGenres;

      // 2. Mapeamento padronizado de gêneros para IDs do TMDB.
      final requestedGenreIds = GenreMapper.toGenreIds(requestedGenres);
      final preferredGenreIds = GenreMapper.toGenreIds(preferredGenres);
      final dislikedGenreIds = GenreMapper.toGenreIds(dislikedGenres);

      List<int> genreIds;
      if (requestedGenreIds.isNotEmpty) {
        genreIds = requestedGenreIds;
      } else {
        genreIds = preferredGenreIds
            .where((id) => !dislikedGenreIds.contains(id))
            .toList();
      }

      // Se o mapeamento direto por ID falhar, consulta a lista completa do TMDB como fallback.
      if (genreIds.isEmpty) {
        final genresResult = await _moviesRepository.getMovieGenres();
        if (genresResult case Ok(:final value)) {
          genreIds = value.take(3).map((g) => g.id).toList();
        }
      }

      // 3. Buscamos filmes reais pelos gêneros identificados.
      final moviesResult = await _moviesRepository.discoverMovies(
        genreIds: genreIds,
      );

      final candidateMovies = switch (moviesResult) {
        Ok(:final value) => value.take(8).toList(),
        Error(:final error) => throw error,
      };

      final durationPreference =
          interpretation['durationPreference'] as String? ?? 'any';

      final movies = await _orderMoviesByDuration(
        candidateMovies,
        durationPreference,
      );

      if (movies.isEmpty) {
        throw Exception('Não encontrei filmes para esses critérios.');
      }

      // 4. Adicionamos a resposta e os filmes ao histórico.
      _messages.add(
        ChatMessage(text: explanation, role: ChatMessageRole.assistant),
      );

      _messages.add(
        ChatMessage(
          text: 'Separei estes filmes para você:',
          role: ChatMessageRole.assistant,
          movies: movies,
        ),
      );
    } catch (error) {
      debugPrint("Error chat: $error");
      _errorMessage = 'Não consegui encontrar os filmes. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Movie>> _orderMoviesByDuration(
    List<Movie> movies,
    String durationPreference,
  ) async {
    if (movies.isEmpty || durationPreference == 'any') {
      return movies.take(3).toList();
    }

    final detailsResults = await Future.wait(
      movies.map((movie) => _moviesRepository.getMovieDetails(movie.id)),
    );

    final runtimeByMovieId = <int, int>{};

    for (var i = 0; i < movies.length; i++) {
      switch (detailsResults[i]) {
        case Ok(:final value):
          final runtime = value.runtime;

          if (runtime != null && runtime > 0) {
            runtimeByMovieId[movies[i].id] = runtime;
          }

        case Error():
          break;
      }
    }

    int durationScore(int? runtime) {
      if (runtime == null) return 0;

      switch (durationPreference) {
        case 'short':
          if (runtime <= 90) return 3;
          if (runtime <= 110) return 2;
          if (runtime <= 130) return 1;
          return 0;

        case 'medium':
          if (runtime >= 100 && runtime <= 130) return 3;
          if (runtime >= 90 && runtime <= 140) return 2;
          return 1;

        case 'long':
          if (runtime > 140) return 3;
          if (runtime > 120) return 2;
          if (runtime >= 100) return 1;
          return 0;

        default:
          return 0;
      }
    }

    final originalOrder = {
      for (var i = 0; i < movies.length; i++) movies[i].id: i,
    };

    final orderedMovies = [...movies];

    orderedMovies.sort((a, b) {
      final scoreA = durationScore(runtimeByMovieId[a.id]);
      final scoreB = durationScore(runtimeByMovieId[b.id]);

      final scoreComparison = scoreB.compareTo(scoreA);

      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return originalOrder[a.id]!.compareTo(originalOrder[b.id]!);
    });

    return orderedMovies.take(3).toList();
  }
}
