
import 'package:flutter/foundation.dart';

import '../../data/services/gemini_service.dart';
import '../../data/repositories/movies_repository.dart';
import '../../utils/result.dart';
import 'chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required GeminiService geminiService,
    required MoviesRepository moviesRepository,
  }) : _geminiService = geminiService,
       _moviesRepository = moviesRepository;

  final GeminiService _geminiService;
  final MoviesRepository _moviesRepository;

  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Future<void> sendMessage(String message) async {
  //   final text = message.trim();

  //   if (text.isEmpty || _isLoading) return;

  //   _messages.add(
  //     ChatMessage(
  //       text: text,
  //       role: ChatMessageRole.user,
  //     ),
  //   );

  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     final result = await _geminiService.interpretPreferences(text);

  //     final explanation = result['explanation'] as String? ??
  //         'Vamos encontrar filmes para você!';

  //     _messages.add(
  //       ChatMessage(
  //         text: explanation,
  //         role: ChatMessageRole.assistant,
  //       ),
  //     );
  //   } catch (error) {
  //     _errorMessage =
  //         'Não consegui consultar a IA. Verifique sua conexão e tente novamente.';
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
  
  Future<void> sendMessage(String message) async {
    final text = message.trim();

    if (text.isEmpty || _isLoading) return;

    _messages.add(
      ChatMessage(
        text: text,
        role: ChatMessageRole.user,
      ),
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. A Gemini interpreta o pedido.
      final interpretation =
          await _geminiService.interpretPreferences(text);

      final explanation =
          interpretation['explanation'] as String? ??
              'Encontrei alguns critérios para sua busca.';

      final rawGenres = interpretation['genres'];

      final requestedGenres = rawGenres is List
          ? rawGenres.whereType<String>().toList()
          : <String>[];

      if (requestedGenres.isEmpty) {
        throw Exception('Não consegui identificar os gêneros desejados.');
      }

      // 2. Consultamos os gêneros disponíveis no TMDB.
      final genresResult = await _moviesRepository.getMovieGenres();

      final genreIds = switch (genresResult) {
        Ok(:final value) => value
            .where(
              (genre) => requestedGenres.any(
                (requested) =>
                    genre.name.trim().toLowerCase() ==
                    requested.trim().toLowerCase(),
              ),
            )
            .map((genre) => genre.id)
            .toList(),
        Error(:final error) => throw error,
      };

      if (genreIds.isEmpty) {
        throw Exception(
          'Não encontrei os gêneros solicitados no TMDB.',
        );
      }

      // 3. Buscamos filmes reais pelos gêneros identificados.
      final moviesResult = await _moviesRepository.discoverMovies(
        genreIds: genreIds,
      );

      final movies = switch (moviesResult) {
        Ok(:final value) => value.take(3).toList(),
        Error(:final error) => throw error,
      };

      if (movies.isEmpty) {
        throw Exception('Não encontrei filmes para esses critérios.');
      }

      // 4. Adicionamos a resposta e os filmes ao histórico.
      _messages.add(
        ChatMessage(
          text: explanation,
          role: ChatMessageRole.assistant,
        ),
      );

      _messages.add(
        ChatMessage(
          text: 'Separei estes filmes para você:',
          role: ChatMessageRole.assistant,
          movies: movies,
        ),
      );
    } catch (error) {
      _errorMessage =
          'Não consegui encontrar os filmes. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
