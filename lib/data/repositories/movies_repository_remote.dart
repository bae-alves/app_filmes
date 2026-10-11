import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/result.dart';
import '../api_models/movie.dart';
import '../api_models/movie_details.dart';
import '../api_models/video.dart';
import '../api_models/watch_providers.dart';
import '../services/tmdb_rest_client.dart';
import 'movies_repository.dart';
import '../api_models/movie_genre.dart';

/// Implementação de [MoviesRepository] apoiada na API do TMDB.
///
/// Concentra a lógica que não pertence nem ao service (que só sabe fazer
/// requisições) nem à view model (que só cuida do estado da tela):
/// cache, tradução de falhas em [Result] e a escolha de qual vídeo
/// é, de fato, "o trailer" do filme.
///
/// As mensagens das exceções devolvidas em [Result.error] são para o log do
/// desenvolvedor, em português. A interface não as exibe: cada tela mostra a
/// sua própria mensagem traduzida (veja `AppLocalizations`).
class MoviesRepositoryRemote implements MoviesRepository {
  MoviesRepositoryRemote({
    required TmdbRestClient restClient,
    required String language,
    required SharedPreferences preferences,
  })  : _restClient = restClient,
        _language = language,
        _preferences = preferences {
    _removeExpiredDetails();
  }

  final TmdbRestClient _restClient;

  /// Armazenamento local (localStorage na web) do cache de detalhes, que
  /// sobrevive ao fechamento do app — veja [getMovieDetails]. As entradas
  /// vencidas são apagadas quando o repositório é criado.
  final SharedPreferences _preferences;

  /// Por quanto tempo os detalhes de um filme salvos localmente valem.
  static const detailsCacheTtl = Duration(hours: 24);

  /// Quantos filmes o cache de detalhes guarda, no máximo. Cada entrada leva a
  /// equipe técnica inteira, e na web o localStorage tem poucos MB.
  static const detailsCacheMaxEntries = 50;

  /// Prefixo das chaves do cache de detalhes (`movie_details:<idioma>:<id>`).
  static const _detailsKeyPrefix = 'movie_details:';

  /// Idioma do conteúdo pedido ao TMDB (ex.: `pt-BR`), o mesmo da interface.
  ///
  /// É fixo durante a vida do repositório, e por isso os caches em memória não
  /// separam entradas por idioma. O de detalhes, que é persistido e sobrevive a
  /// uma troca de idioma, separa. Em produção vem de `currentTmdbLanguage`.
  final String _language;

  /// Páginas de populares já carregadas, indexadas pelo número da página.
  final Map<int, List<Movie>> _popularCache = {};

  /// Disponibilidade em streaming já carregada, indexada pelo id do filme.
  ///
  /// Guarda o mapa de **todos os países** devolvido pelo TMDB, e não só o da
  /// região pedida: se a região do usuário mudar, a resposta sai do cache sem
  /// nova chamada de rede.
  final Map<int, Map<String, WatchProviderRegion>> _watchProvidersCache = {};

  @override
  Future<Result<List<Movie>>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final cached = _popularCache[page];
    if (cached != null && !forceRefresh) return Result.ok(cached);

    try {
      final response = await _restClient.getPopularMovies(
        page: page,
        language: _language,
      );
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

  /// Os detalhes ficam salvos localmente por [detailsCacheTtl]: reabrir o
  /// filme, inclusive depois de reiniciar o app, não depende da API.
  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async {
    final cacheKey = '$_detailsKeyPrefix$_language:$movieId';
    final cached = _readCachedDetails(cacheKey);
    if (cached != null) return Result.ok(cached);

    final MovieDetails details;
    try {
      final response = await _restClient.getMovieDetails(
        movieId,
        language: _language,
      );
      if (!_isSuccess(response.response.statusCode)) {
        return Result.error(
          _httpException('Falha ao carregar os detalhes do filme', response.response),
        );
      }
      details = response.data;
    } on Object catch (error) {
      return Result.error(
        _asException('Falha ao carregar os detalhes do filme', error),
      );
    }

    // Salvar é só um extra: se falhar (ex.: localStorage cheio na web), a tela
    // abre do mesmo jeito.
    try {
      await _evictOldestDetails(keep: cacheKey);
      await _preferences.setString(
        cacheKey,
        jsonEncode({
          'savedAt': DateTime.now().millisecondsSinceEpoch,
          'details': details.toJson(),
        }),
      );
    } on Object catch (error) {
      if (kDebugMode) debugPrint('Não foi possível salvar o filme $movieId: $error');
    }
    return Result.ok(details);
  }

  @override
  Future<Result<Video?>> getMovieTrailer(int movieId) async {
    try {
      // Boa parte dos filmes não tem vídeo cadastrado fora do inglês. Antes de
      // dizer que não há trailer, tentamos o catálogo em en-US — a não ser que
      // ele já tenha sido o primeiro pedido.
      var videos = await _fetchVideos(movieId, language: _language);
      if (videos.isEmpty && _language != tmdbFallbackLanguage) {
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
        language: _language,
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
        language: _language,
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
      final response = await _restClient.getMovieGenres(language: _language);

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

  @override
  Future<Result<WatchProviderRegion?>> getWatchProviders(
    int movieId, {
    required String region,
  }) async {
    var byRegion = _watchProvidersCache[movieId];
    if (byRegion == null) {
      try {
        final response = await _restClient.getWatchProviders(movieId);
        if (!_isSuccess(response.response.statusCode)) {
          return Result.error(
            _httpException('Falha ao carregar onde assistir', response.response),
          );
        }

        byRegion = response.data.results ?? const {};
        _watchProvidersCache[movieId] = byRegion;
      } on Object catch (error) {
        return Result.error(
          _asException('Falha ao carregar onde assistir', error),
        );
      }
    }

    // País ausente e país presente mas sem nenhum serviço significam a mesma
    // coisa para quem consome: o filme não está disponível ali.
    final providers = byRegion[region.toUpperCase()];
    return Result.ok(providers == null || providers.isEmpty ? null : providers);
  }

  /// Detalhes salvos em [key], ou `null` se não houver, se tiverem vencido ou
  /// se a entrada estiver corrompida (ex.: formato de uma versão anterior).
  MovieDetails? _readCachedDetails(String key) {
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt =
          DateTime.fromMillisecondsSinceEpoch(entry['savedAt'] as int);
      final age = DateTime.now().difference(savedAt);
      // Idade negativa: o relógio do aparelho voltou no tempo. Sem essa
      // checagem a entrada valeria até o relógio alcançar a data salva.
      if (age.isNegative || age > detailsCacheTtl) return null;
      return MovieDetails.fromJson(entry['details'] as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  /// Apaga os detalhes salvos que venceram ou estão corrompidos. Sem isso o
  /// armazenamento só cresce, e na web o localStorage tem poucos MB.
  void _removeExpiredDetails() {
    for (final key in _preferences.getKeys()) {
      if (key.startsWith(_detailsKeyPrefix) && _readCachedDetails(key) == null) {
        _preferences.remove(key);
      }
    }
  }

  /// Apaga os detalhes salvos mais antigos até caber mais um filme sem passar
  /// de [detailsCacheMaxEntries]. [keep] é a entrada que vai ser sobrescrita:
  /// não ocupa espaço novo, então não entra na conta.
  Future<void> _evictOldestDetails({required String keep}) async {
    final entries = [
      for (final key in _preferences.getKeys())
        if (key.startsWith(_detailsKeyPrefix) && key != keep)
          (key: key, savedAt: _savedAt(key)),
    ]..sort((a, b) => a.savedAt.compareTo(b.savedAt));
    final excess = entries.length - detailsCacheMaxEntries + 1;
    if (excess <= 0) return;
    for (final entry in entries.take(excess)) {
      await _preferences.remove(entry.key);
    }
  }

  /// Quando a entrada em [key] foi salva, ou 0 se estiver corrompida — assim
  /// ela é a primeira a sair.
  int _savedAt(String key) {
    try {
      final entry =
          jsonDecode(_preferences.getString(key)!) as Map<String, dynamic>;
      return entry['savedAt'] as int;
    } on Object {
      return 0;
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
