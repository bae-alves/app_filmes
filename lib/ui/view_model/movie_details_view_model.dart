import 'package:flutter/foundation.dart';

import '../../data/api_models/movie_details.dart';
import '../../data/api_models/video.dart';
import '../../data/api_models/watch_providers.dart';
import '../../data/repositories/movies_repository.dart';
import '../../utils/result.dart';

/// View model da tela de detalhes: reúne os dados do filme, o seu trailer e
/// onde ele pode ser assistido.
///
/// Recebe apenas o [movieId] (e a região do usuário) porque a tela é
/// auto-suficiente — abrir a mesma rota a partir de qualquer lugar do app
/// produz o mesmo resultado.
class MovieDetailsViewModel extends ChangeNotifier {
  MovieDetailsViewModel({
    required MoviesRepository moviesRepository,
    required this.movieId,
    required this.watchRegion,
  }) : _moviesRepository = moviesRepository;

  final MoviesRepository _moviesRepository;

  /// Id do filme exibido pela tela.
  final int movieId;

  /// País (ISO 3166-1, ex.: `BR`) usado para consultar onde assistir.
  ///
  /// É injetado, e não lido aqui dentro, para que os testes controlem a região
  /// e para que a origem do valor possa mudar sem tocar na view model — hoje
  /// ele vem de `currentWatchRegion` em `main.dart`.
  final String watchRegion;

  MovieDetails? _details;
  Video? _trailer;
  WatchProviderRegion? _watchProviders;
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

  /// Serviços onde o filme pode ser assistido na [watchRegion], ou `null`
  /// quando ele não está disponível em nenhum (ou a consulta falhou).
  WatchProviderRegion? get watchProviders => _watchProviders;

  /// Indica que há uma requisição em andamento.
  bool get isLoading => _isLoading;

  /// Erro que impediu a exibição dos detalhes, ou `null`.
  Exception? get error => _error;

  /// Carrega detalhes, trailer e onde assistir o filme.
  ///
  /// As três chamadas partem juntas para não somar as latências. As falhas do
  /// trailer e de onde assistir são toleradas de propósito: sem elas, o filme
  /// ainda tem informações que valem a pena mostrar.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final detailsRequest = _moviesRepository.getMovieDetails(movieId);
    final trailerRequest = _moviesRepository.getMovieTrailer(movieId);
    final watchProvidersRequest = _moviesRepository.getWatchProviders(
      movieId,
      region: watchRegion,
    );

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

    switch (await watchProvidersRequest) {
      case Ok<WatchProviderRegion?>(:final value):
        _watchProviders = value;
      case Error<WatchProviderRegion?>(:final error):
        // ponytail: falha vira "indisponível" na tela; criar um estado de erro
        // próprio se usuários reclamarem de falso negativo.
        _watchProviders = null;
        if (kDebugMode) {
          debugPrint(
            'Não foi possível carregar onde assistir o filme $movieId: $error',
          );
        }
    }

    _isLoading = false;
    notifyListeners();
  }
}
