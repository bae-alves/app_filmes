import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/movie_page_response.dart';
import 'package:app_filmes/data/api_models/videos_response.dart';
import 'package:app_filmes/data/services/tmdb_rest_client.dart';
import 'package:app_filmes/data/api_models/movie_genres_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

/// Cliente REST falso: substitui a camada de service nos testes do repositório.
///
/// Permite simular respostas de sucesso, status HTTP de erro e exceções de
/// rede, além de registrar os parâmetros recebidas em cada chamada.
class FakeTmdbRestClient implements TmdbRestClient {
  FakeTmdbRestClient({
    this.popularPage = const MoviePageResponse(),
    this.details,
    this.videosByLanguage = const {},
  });

  /// Resposta devolvida por [getPopularMovies].
  MoviePageResponse popularPage;

  /// Resposta devolvida por [getMovieDetails].
  MovieDetails? details;

  /// Vídeos por idioma solicitado. Idiomas ausentes devolvem lista vazia,
  /// exatamente como o TMDB faz quando não há tradução cadastrada.
  Map<String?, VideosResponse> videosByLanguage;

  /// Status HTTP devolvido em todas as respostas.
  int statusCode = 200;

  /// Quando definido, todas as chamadas lançam esta exceção.
  Object? errorToThrow;

  /// Quantidade de chamadas a [getPopularMovies].
  int popularCallCount = 0;

  /// Quantidade de chamadas a [getMovieDetails].
  int detailsCallCount = 0;

  /// Idiomas pedidos a [getMovieVideos], na ordem das chamadas.
  final List<String?> requestedVideoLanguages = [];

  @override
  Future<HttpResponse<MoviePageResponse>> getPopularMovies({
    int page = 1,
    String language = tmdbDefaultLanguage,
  }) async {
    popularCallCount++;
    _maybeThrow();
    return _wrap(popularPage);
  }

  @override
  Future<HttpResponse<MoviePageResponse>> searchMovies({
    required String query,
    int page = 1,
    String language = tmdbDefaultLanguage,
    bool includeAdult = false,
  }) async {
    _maybeThrow();
    return _wrap(popularPage);
  }

  @override
  Future<HttpResponse<MoviePageResponse>> discoverMovies({
    String? withGenres,
    int page = 1,
    String language = tmdbDefaultLanguage,
    String sortBy = 'popularity.desc',
  }) async {
    _maybeThrow();
    return _wrap(popularPage);
  }

  @override
  Future<HttpResponse<MovieGenresResponse>> getMovieGenres({
    String language = tmdbDefaultLanguage,
  }) async {
    _maybeThrow();
    return _wrap(const MovieGenresResponse());
  }

  @override
  Future<HttpResponse<MovieDetails>> getMovieDetails(
    int movieId, {
    String language = tmdbDefaultLanguage,
  }) async {
    detailsCallCount++;
    _maybeThrow();
    return _wrap(details ?? MovieDetails(id: movieId));
  }

  @override
  Future<HttpResponse<VideosResponse>> getMovieVideos(
    int movieId, {
    String? language,
  }) async {
    requestedVideoLanguages.add(language);
    _maybeThrow();
    return _wrap(
      videosByLanguage[language] ?? const VideosResponse(results: []),
    );
  }

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  HttpResponse<T> _wrap<T>(T data) => HttpResponse<T>(
        data,
        Response<dynamic>(
          requestOptions: RequestOptions(path: '/fake'),
          statusCode: statusCode,
        ),
      );
}
