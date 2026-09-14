import 'package:dio/dio.dart';

import '../../utils/result.dart';
import '../api_models/movie.dart';
import '../api_models/movie_details.dart';
import '../api_models/video.dart';
import '../services/tmdb_rest_client.dart';
import 'movies_repository.dart';
import '../api_models/movie_genre.dart';

/// Implementação de [MoviesRepository] apoiada na API do TMDB.
///
/// Concentra a lógica que não pertence nem ao service (que só sabe fazer
/// requisições) nem à view model (que só cuida do estado da tela):
/// cache em memória, tradução de falhas em [Result] e a escolha de qual vídeo
/// é, de fato, "o trailer" do filme.
class MoviesRepositoryRemote implements MoviesRepository {
  MoviesRepositoryRemote({required TmdbRestClient restClient})
      : _restClient = restClient;

  final TmdbRestClient _restClient;

  /// Páginas de populares já carregadas, indexadas pelo número da página.
  final Map<int, List<Movie>> _popularCache = {};

  /// Detalhes já carregados, indexados pelo id do filme. Evita nova chamada de
  /// rede quando o usuário volta para a home e reabre o mesmo filme.
  final Map<int, MovieDetails> _detailsCache = {};

  @override
  Future<Result<List<Movie>>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cached = _popularCache[page];
    if (cached != null && !forceRefresh) return Result.ok(cached);

    try {
      final response = await _restClient.getPopularMovies(page: page);
      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException('Falha ao carregar os filmes populares', response.response),
        );
      }

      final movies = response.data.results ?? const <Movie>[];
      _popularCache[page] = movies;
      return Result.ok(movies);
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao carregar os filmes populares', error),
      );
    }
  }

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async {
    final cached = _detailsCache[movieId];
    if (cached != null) return Result.ok(cached);

    try {
      final response = await _restClient.getMovieDetails(movieId);
      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException('Falha ao carregar os detalhes do filme', response.response),
        );
      }

      final details = response.data;
      _detailsCache[movieId] = details;
      return Result.ok(details);
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao carregar os detalhes do filme', error),
      );
    }
  }

  @override
  Future<Result<Video?>> getMovieTrailer(int movieId) async {
    try {
      // Boa parte dos filmes não tem vídeo cadastrado em pt-BR. Antes de dizer
      // que não há trailer, tentamos o catálogo original (en-US).
      var videos = await _fetchVideos(movieId, language: tmdbDefaultLanguage);
      if (videos.isEmpty) {
        videos = await _fetchVideos(movieId, language: tmdbFallbackLanguage);
      }
      return Result.ok(_pickBestTrailer(videos));
    } on Object catch (error) {
      return Result.error(_asException('Falha ao carregar o trailer', error));
    }
  }

  @override
  Future<Result<List<Movie>>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _restClient.searchMovies(
        query: query,
        page: page,
      );

      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException(
            'Falha ao pesquisar filmes',
            response.response,
          ),
        );
      }

      final movies = response.data.results ?? const <Movie>[];
      return Result.ok(movies);
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao pesquisar filmes', error),
      );
    }
  }

  @override
  Future<Result<List<Movie>>> discoverMovies({
    List<int>? genreIds,
    int page = 1,
  }) async {
    try {
      final withGenres = genreIds?.isNotEmpty == true
          ? genreIds!.join(',')
          : null;

      final response = await _restClient.discoverMovies(
        withGenres: withGenres,
        page: page,
      );

      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException(
            'Falha ao filtrar filmes',
            response.response,
          ),
        );
      }

      final movies = response.data.results ?? const <Movie>[];
      return Result.ok(movies);
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao filtrar filmes', error),
      );
    }
  }

  @override
  Future<Result<List<MovieGenre>>> getMovieGenres() async {
    try {
      final response = await _restClient.getMovieGenres();

      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException(
            'Falha ao carregar os gêneros',
            response.response,
          ),
        );
      }

      final genres = response.data.genres ?? const <MovieGenre>[];
      return Result.ok(genres);
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao carregar os gêneros', error),
      );
    }
  }

  Future<List<Video>> _fetchVideos(int movieId, {required String language}) async {
    final response = await _restClient.getMovieVideos(movieId, language: language);
    if (!_isSuccess(response.response.statusCode)) {
      throw _httpException('Falha ao carregar o trailer', response.response);
    }
    return response.data.results ?? const <Video>[];
  }

  /// Escolhe o vídeo que melhor representa o trailer do filme.
  ///
  /// A API devolve a lista sem ordem de relevância e misturando categorias, por
  /// isso a preferência é, nesta ordem: trailer oficial, trailer, teaser
  /// oficial, teaser e, por fim, qualquer vídeo do YouTube.
  static Video? _pickBestTrailer(List<Video> videos) {
    // Só sabemos reproduzir vídeos do YouTube, e sem a chave não há o que tocar.
    final playable = videos
        .where((video) => video.site == 'YouTube' && (video.key?.isNotEmpty ?? false))
        .toList();
    if (playable.isEmpty) return null;

    Video? firstWhereOrNull(bool Function(Video) test) {
      for (final video in playable) {
        if (test(video)) return video;
      }
      return null;
    }

    return firstWhereOrNull((v) => v.type == 'Trailer' && v.official == true) ??
        firstWhereOrNull((v) => v.type == 'Trailer') ??
        firstWhereOrNull((v) => v.type == 'Teaser' && v.official == true) ??
        firstWhereOrNull((v) => v.type == 'Teaser') ??
        playable.first;
  }

  static bool _isSuccess(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  static Exception _httpException(String context, Response<dynamic> response) =>
      Exception('$context (HTTP ${response.statusCode}).');

  /// Converte qualquer falha em uma [Exception] com mensagem apresentável.
  ///
  /// Erros de rede chegam como [DioException]; erros de desserialização chegam
  /// como `TypeError`, que não é `Exception` — por isso capturamos `Object`.
  static Exception _asException(String context, Object error) {
    if (error is Exception && error is! DioException) return error;
    if (error is DioException) {
      final status = error.response?.statusCode;
      final detail = status != null ? 'HTTP $status' : error.type.name;
      return Exception('$context ($detail).');
    }
    return Exception('$context: $error');
  }
}
