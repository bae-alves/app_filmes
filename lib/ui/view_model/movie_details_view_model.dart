import 'package:flutter/foundation.dart';

import '../../data/api_models/movie_details.dart';
import '../../data/api_models/video.dart';
import '../../data/repositories/movies_repository.dart';
import '../../utils/result.dart';

/// View model da tela de detalhes: reúne os dados do filme e o seu trailer.
///
/// Recebe apenas o [movieId] porque a tela é auto-suficiente — abrir a mesma
/// rota a partir de qualquer lugar do app produz o mesmo resultado.
class MovieDetailsViewModel extends ChangeNotifier {
  MovieDetailsViewModel({
    required MoviesRepository moviesRepository,
    required this.movieId,
  }) : _moviesRepository = moviesRepository;

  final MoviesRepository _moviesRepository;

  /// Id do filme exibido pela tela.
  final int movieId;

  MovieDetails? _details;
  Video? _trailer;
  bool _isLoading = false;
  Exception? _error;

  /// Informações do filme, disponíveis após um [load] bem-sucedido.
  MovieDetails? get details => _details;

  /// Trailer escolhido pelo repositório, ou `null` quando o filme não tem um.
  Video? get trailer => _trailer;

  /// Chave do vídeo no YouTube, pronta para ser entregue ao player.
  String? get trailerYoutubeKey {
    final key = _trailer?.key;
    return (key == null || key.isEmpty) ? null : key;
  }

  /// Indica que há uma requisição em andamento.
  bool get isLoading => _isLoading;

  /// Erro que impediu a exibição dos detalhes, ou `null`.
  Exception? get error => _error;

  /// Carrega detalhes e trailer do filme.
  ///
  /// As duas chamadas partem juntas para não somar as latências. A falha do
  /// trailer é tolerada de propósito: um filme sem trailer ainda tem
  /// informações que valem a pena mostrar.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final detailsRequest = _moviesRepository.getMovieDetails(movieId);
    final trailerRequest = _moviesRepository.getMovieTrailer(movieId);

    switch (await detailsRequest) {
      case Ok<MovieDetails>(:final value):
        _details = value;
      case Error<MovieDetails>(:final error):
        _details = null;
        _error = error;
    }

    switch (await trailerRequest) {
      case Ok<Video?>(:final value):
        _trailer = value;
      case Error<Video?>(:final error):
        _trailer = null;
        if (kDebugMode) {
          debugPrint('Não foi possível carregar o trailer do filme $movieId: $error');
        }
    }

    _isLoading = false;
    notifyListeners();
  }
}
