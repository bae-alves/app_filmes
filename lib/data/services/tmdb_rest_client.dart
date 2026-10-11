import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../api_models/movie_details.dart';
import '../api_models/movie_page_response.dart';
import '../api_models/videos_response.dart';
import '../api_models/movie_genres_response.dart';
import '../api_models/watch_providers.dart';

part 'tmdb_rest_client.g.dart';

/// Camada mais baixa da aplicação: encapsula os endpoints REST do TMDB.
///
/// O service não tem estado nem regra de negócio — apenas descreve verbo,
/// caminho, parâmetros e o tipo de retorno. O retrofit gera a implementação
/// (`tmdb_rest_client.g.dart`) a partir destas anotações:
///
/// ```sh
/// dart run build_runner build --delete-conflicting-outputs
/// ```
///
/// A autenticação (header `Authorization: Bearer ...`) é responsabilidade do
/// [Dio] injetado — veja `createTmdbDio`.
///
/// O parâmetro `language` (ex.: `pt-BR`) é obrigatório em todos os endpoints
/// que devolvem texto: quem escolhe o idioma é o repositório, a partir do
/// idioma do app. Não há valor padrão de propósito — um padrão silencioso
/// faria o conteúdo voltar em português para quem usa o app em inglês.
///
/// Documentação: https://developer.themoviedb.org/docs/getting-started
@RestApi(baseUrl: tmdbBaseUrl)
abstract class TmdbRestClient {
  factory TmdbRestClient(Dio dio, {String? baseUrl}) = _TmdbRestClient;

  /// Filmes populares do momento, paginados.
  ///
  /// Retornamos [HttpResponse] (e não só o modelo) para que o repositório
  /// consiga inspecionar o status HTTP antes de aceitar o corpo da resposta.
  @GET('/movie/popular')
  Future<HttpResponse<MoviePageResponse>> getPopularMovies({
    @Query('page') int page = 1,
    @Query('language') required String language,
  });

  /// Detalhes de um filme específico.
  @GET('/movie/{movie_id}')
  Future<HttpResponse<MovieDetails>> getMovieDetails(
    @Path('movie_id') int movieId, {
    @Query('language') required String language,
  });

  /// Vídeos (trailers, teasers, clipes) de um filme.
  ///
  /// [language] é opcional de propósito: quando não há vídeo no idioma pedido,
  /// o repositório repete a chamada em outro idioma.
  @GET('/movie/{movie_id}/videos')
  Future<HttpResponse<VideosResponse>> getMovieVideos(
    @Path('movie_id') int movieId, {
    @Query('language') String? language,
  });

  @GET('/search/movie')
  Future<HttpResponse<MoviePageResponse>> searchMovies({
    @Query('query') required String query,
    @Query('page') int page = 1,
    @Query('language') required String language,
    @Query('include_adult') bool includeAdult = false,
  });

  @GET('/discover/movie')
  Future<HttpResponse<MoviePageResponse>> discoverMovies({
    @Query('with_genres') String? withGenres,
    @Query('page') int page = 1,
    @Query('language') required String language,
    @Query('sort_by') String sortBy = 'popularity.desc',
  });

  @GET('/genre/movie/list')
  Future<HttpResponse<MovieGenresResponse>> getMovieGenres({
    @Query('language') required String language,
  });

  /// Serviços de streaming, aluguel e compra onde o filme está disponível.
  ///
  /// A resposta traz **todos os países** de uma vez — não há parâmetro de
  /// região nem de idioma. Escolher o país do usuário é papel do repositório.
  @GET('/movie/{movie_id}/watch/providers')
  Future<HttpResponse<WatchProvidersResponse>> getWatchProviders(
    @Path('movie_id') int movieId,
  );
}

/// URL base da API v3 do TMDB.
const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

/// Idioma do TMDB para cada idioma da interface, indexado pelo código de
/// idioma do Flutter (`Locale.languageCode`).
///
/// O TMDB devolve título, sinopse e gêneros traduzidos quando existe tradução
/// cadastrada. Ao adicionar um idioma ao app (um novo `app_<idioma>.arb`),
/// adicione também a entrada correspondente aqui — sem ela, o conteúdo cai
/// para [tmdbFallbackLanguage]. Quem consulta este mapa é `tmdbLanguageFor`
/// (lib/utils/user_locale.dart).
const Map<String, String> tmdbLanguages = {
  'pt': 'pt-BR',
  'en': 'en-US',
};

/// Idioma usado quando a interface está num idioma sem entrada em
/// [tmdbLanguages], e como segunda tentativa quando não há trailer no idioma
/// do app — é o idioma com mais conteúdo cadastrado no TMDB.
const String tmdbFallbackLanguage = 'en-US';

/// País usado para consultar onde assistir quando o dispositivo não informa
/// uma região (ex.: navegador configurado só com `en`, sem país).
///
/// Código ISO 3166-1 de duas letras, o mesmo formato das chaves de
/// [WatchProvidersResponse.results]. A região do usuário é obtida em
/// `currentWatchRegion` (lib/utils/user_locale.dart).
const String tmdbFallbackWatchRegion = 'BR';
