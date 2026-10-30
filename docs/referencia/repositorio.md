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

## `FavoritesRepository`

`lib/data/repositories/favorites_repository.dart`. Lista de favoritos
(watchlist). A implementação de produção é `FavoritesRepositoryLocal`, em
SQLite no aparelho. A de teste é `FakeFavoritesRepository` (`test/fakes/`).
Por que local, e o que muda com login:
[Favoritos](../explicacao/favoritos.md).

| Método | `T` | Comportamento |
| --- | --- | --- |
| `getFavorites()` | `List<Favorite>` | Do adicionado mais recentemente ao mais antigo. `Favorite` traz o `movie` e o `addedAt`. |
| `addFavorite(movie, {addedAt})` | `void` | Grava o resumo do filme com `addedAt` (padrão: agora), que define a posição na lista. Se o filme já está lá, atualiza o resumo. "Desfazer" passa o `addedAt` original para o filme voltar ao mesmo lugar. |
| `removeFavorite(movieId)` | `void` | Remove. Remover um filme ausente não é erro. |

Assim como em `MoviesRepository`, nada lança: falhas do banco viram
`Error`, com mensagem em português para o log.

### Construtor de `FavoritesRepositoryLocal`

| Parâmetro | Tipo | Descrição |
| --- | --- | --- |
| `database` | `Database` (sqflite) | Banco aberto por `AppDatabase.open()`. |
| `now` | `DateTime Function()?` | Relógio de `added_at` quando `addFavorite` não recebe `addedAt`. Padrão: `DateTime.now`. |

### `AppDatabase`

`lib/data/services/app_database.dart`. Abre o banco `app_filmes.db`
(esquema versão 1), com a tabela `favorites`: `movie_id` (chave), `title`,
`original_title`, `overview`, `poster_path`, `backdrop_path`,
`release_date`, `vote_average`, `vote_count` e `added_at` (milissegundos
desde 1970). `open({factory, path})` aceita uma fábrica e um caminho para os
testes abrirem um banco em memória.
