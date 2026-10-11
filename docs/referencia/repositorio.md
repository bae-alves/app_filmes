# Referência: repositório

`MoviesRepository` (`lib/data/repositories/movies_repository.dart`) é a única
fonte de dados de filmes da UI. A implementação de produção é
`MoviesRepositoryRemote`; a de teste é `FakeMoviesRepository`
(`test/fakes/`).

## Construtor de `MoviesRepositoryRemote`

| Parâmetro | Tipo | Descrição |
| --- | --- | --- |
| `restClient` | `TmdbRestClient` | Service do TMDB. |
| `language` | `String` | Idioma do conteúdo (`pt-BR`, `en-US`). Fixo durante a vida do repositório. |
| `preferences` | `SharedPreferences` | Onde o cache de detalhes é salvo. Ao criar o repositório, as entradas vencidas são apagadas. |

## Métodos

Todos devolvem `Future<Result<T>>`: `Ok(value)` ou `Error(exception)`.
Nenhum lança exceção.

| Método | `T` | Endpoint | Cache |
| --- | --- | --- | --- |
| `getPopularMovies({page = 1, forceRefresh = false})` | `List<Movie>` | `/movie/popular` | Por página. `forceRefresh` ignora o cache. |
| `searchMovies({required query, page = 1})` | `List<Movie>` | `/search/movie` | Não |
| `discoverMovies({genreIds, page = 1})` | `List<Movie>` | `/discover/movie` | Não |
| `getMovieGenres()` | `List<MovieGenre>` | `/genre/movie/list` | Não (a `HomeViewModel` guarda a lista) |
| `getMovieDetails(movieId)` | `MovieDetails` | `/movie/{id}?append_to_response=credits,release_dates` | Por filme e idioma, salvo no aparelho (`shared_preferences`) por 24h, até 50 filmes (`detailsCacheMaxEntries`; cheio, sai o salvo há mais tempo). Sobrevive ao reinício do app. |
| `getMovieTrailer(movieId)` | `Video?` | `/movie/{id}/videos` | Não |
| `getWatchProviders(movieId, {required region})` | `WatchProviderRegion?` | `/movie/{id}/watch/providers` | Por filme, com todos os países |

## O que `null` significa

`Ok(null)` é sucesso, não erro:

| Método | `Ok(null)` quer dizer |
| --- | --- |
| `getMovieTrailer` | O filme não tem vídeo do YouTube publicado. |
| `getWatchProviders` | O filme não está em nenhum serviço no país `region` (país ausente ou sem serviços). |

## Escolha do trailer

1. Busca vídeos no idioma do repositório.
2. Se vier vazio e o idioma não for `en-US`, busca em `en-US`.
3. Considera só vídeos do YouTube com `key`.
4. Escolhe, nesta ordem: trailer oficial, trailer, teaser oficial, teaser,
   primeiro vídeo.

## Erros

`Error.error` é uma `Exception` com mensagem em português, para log. Formato:
`<contexto> (HTTP <status>).` ou `<contexto> (<tipo do erro de rede>).` A UI
não exibe essa mensagem.

| Falha | Origem |
| --- | --- |
| Status fora de 2xx | Resposta do TMDB |
| `DioException` | Rede, timeout, status ≥ 400 |
| `TypeError` e outros | JSON fora do formato esperado |
