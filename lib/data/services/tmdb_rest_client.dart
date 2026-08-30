import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../api_models/movie_details.dart';
import '../api_models/movie_page_response.dart';
import '../api_models/videos_response.dart';

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
    @Query('language') String language = tmdbDefaultLanguage,
  });

  /// Detalhes de um filme específico.
  @GET('/movie/{movie_id}')
  Future<HttpResponse<MovieDetails>> getMovieDetails(
    @Path('movie_id') int movieId, {
    @Query('language') String language = tmdbDefaultLanguage,
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
}

/// URL base da API v3 do TMDB.
const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

/// Idioma padrão das requisições. O TMDB devolve título e sinopse traduzidos
/// quando existe tradução cadastrada.
const String tmdbDefaultLanguage = 'pt-BR';

/// Idioma usado como alternativa quando não há conteúdo em [tmdbDefaultLanguage].
const String tmdbFallbackLanguage = 'en-US';
