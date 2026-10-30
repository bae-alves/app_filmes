# Referência: testes

```sh
flutter test      # suíte inteira, offline
flutter analyze   # análise estática
```

O `.env` precisa existir, mesmo vazio (a cópia do `.env.example` serve): o
`flutter test` empacota os assets e falha sem ele, com
`No file or variants found for asset: .env`.

## Arquivos

| Arquivo | Testes | O que verifica |
| --- | --- | --- |
| `test/utils/formatters_test.dart` | 10 | Ano, duração e nota, em pt e en. |
| `test/utils/user_locale_test.dart` | 4 | Idioma do TMDB a partir dos idiomas do dispositivo. |
| `test/data/api_models/movie_details_test.dart` | 5 | Diretores, classificação indicativa por país e ida e volta do JSON do cache. |
| `test/data/api_models/watch_providers_test.dart` | 5 | Grupos de onde assistir: ordem, "Grátis" sem repetir serviço, prioridade, grupo vazio omitido e a lista sem repetição do modo compacto. |
| `test/data/repositories/favorites_repository_local_test.dart` | 6 | Favoritos no SQLite (em memória, via `sqflite_common_ffi`): ordem, sem duplicar, `addedAt` devolve à posição, remoção, falha do banco vira `Error`. |
| `test/data/repositories/ratings_repository_local_test.dart` | 8 | Avaliações no SQLite: nota e humor, só humor, troca, remoção, humor desconhecido, nota fora de 1 a 5 recusada pelo banco, falha vira `Error`. |
| `test/data/services/app_database_test.dart` | 1 | Banco da versão 1 sobe para a 2: ganha `ratings` e mantém os favoritos. |
| `test/data/repositories/movies_repository_remote_test.dart` | 26 | Cache (inclusive o salvo no aparelho e o seu limite), erros HTTP e de rede, escolha do trailer, onde assistir por região, idioma enviado ao TMDB. |
| `test/ui/view_model/favorites_view_model_test.dart` | 8 | Leitura, erro, favoritar e desfavoritar, remover e desfazer no mesmo lugar, e a lista que volta quando a gravação falha. |
| `test/ui/view_model/home_view_model_test.dart` | 11 | Estados de carregamento e erro da home, limpar filtros, pesquisa e gêneros um de cada vez, e a busca mais recente que vence quando duas se cruzam. |
| `test/ui/view_model/movie_rating_view_model_test.dart` | 6 | Leitura, nota e humor sem apagar um ao outro, desmarcar, a avaliação que volta quando a gravação falha, e leitura e gravação que terminam depois do `dispose`. |
| `test/ui/view_model/movie_details_view_model_test.dart` | 11 | Detalhes, trailer e onde assistir; falhas toleradas e a de onde assistir sinalizada; diretores e elenco em ordem; carga que termina depois do `dispose`. |
| `test/ui/view/home_to_details_navigation_test.dart` | 21 | Navegação da home aos detalhes, em pt e en, o elenco com fonte grande e o "Ver todos", a falha em onde assistir, o link de onde assistir aberto fora do app, os detalhes que sobrevivem a uma reconstrução do app, as view models descartadas ao voltar, limpar a pesquisa, gêneros que apagam a pesquisa e o fim das listas acima da barra de navegação. |
| `test/ui/view/favorites_test.dart` | 9 | Favoritar nos detalhes e ver na lista, abrir e desfavoritar a partir da lista, remover pela lixeira e arrastando, desfazer, lista vazia, erro, en. |
| `test/ui/view/rating_test.dart` | 5 | Seção abaixo da sinopse, avaliar e reabrir, desmarcar, avaliar a partir dos favoritos, en. |
| `test/ui/view/watch_providers_section_test.dart` | 7 | Grupos, ordem, toque no logo e no botão entregue a `onOpenLink`, sem botão quando não há `onOpenLink`, indisponível, modo compacto, pt e en. |

## Fakes

Em `test/fakes/`. Substituem a rede; os testes rodam offline.

### `FakeTmdbRestClient`

Substitui o service nos testes do repositório. O armazenamento do cache de
detalhes vem de `SharedPreferences.setMockInitialValues`, em memória.

| Membro | Descrição |
| --- | --- |
| `popularPage`, `details`, `videosByLanguage`, `watchProviders` | Respostas devolvidas. |
| `statusCode` | Status HTTP de todas as respostas (padrão 200). |
| `errorToThrow` | Se definido, toda chamada lança. |
| `popularCallCount`, `detailsCallCount`, `watchProvidersCallCount` | Contagem de chamadas. |
| `requestedLanguages` | Idiomas recebidos pelos endpoints com `language` obrigatório. |
| `requestedVideoLanguages` | Idiomas pedidos a `getMovieVideos`. |

### `FakeFavoritesRepository`

Lista de favoritos em memória, ordenada por `addedAt` como o repositório real.

| Membro | Descrição |
| --- | --- |
| construtor `movies` | Filmes iniciais, já na ordem da lista (o primeiro é o mais recente). |
| `favorites`, `movieIds` | Lista guardada (`Favorite`s) e os ids, do mais recente ao mais antigo. |
| `readError` | Se definido, `getFavorites` devolve `Error`. |
| `writeError` | Se definido, `addFavorite` e `removeFavorite` devolvem `Error`. |

### `FakeRatingsRepository`

Avaliações em memória.

| Membro | Descrição |
| --- | --- |
| `ratings` | Avaliações guardadas, por id do filme. O construtor aceita as iniciais. |
| `readError` | Se definido, `getRating` devolve `Error`. |
| `writeError` | Se definido, `saveRating` e `removeRating` devolvem `Error`. |

### `FakeMoviesRepository`

Substitui o repositório nos testes de view model e de widget.

| Membro | Descrição |
| --- | --- |
| `popularMovies`, `searchMoviesResult`, `discoverMoviesResult`, `movieGenres` | Listas devolvidas. |
| `detailsById`, `trailersById` | Dados por id de filme. Id ausente = sem detalhes / sem trailer. |
| `watchProvidersById` | Por filme e por país. Ausente = indisponível. |
| `popularError`, `searchError`, `discoverError`, `genresError`, `detailsError`, `trailerError`, `watchProvidersError` | Se definido, o método devolve `Error`. |
| `requestedDetailIds`, `requestedTrailerIds`, `requestedWatchRegions` | Argumentos recebidos. |
| `forcedRefreshCount` | Chamadas com `forceRefresh: true`. |

## Fixtures

`test/fakes/movie_fixtures.dart`, no formato do TMDB.

| Fixture | Conteúdo |
| --- | --- |
| `dunaId`, `dunaMovie`, `dunaDetails`, `dunaTrailer` | Filme completo, com trailer, elenco, direção e classificação em BR e US. |
| `matrixId`, `matrixMovie`, `matrixDetails` | Filme sem trailer, sem créditos e sem campos opcionais. |
| `netflix`, `maxStreaming`, `appleTv` | Serviços de streaming. |
| `dunaProvidersBr`, `dunaProvidersUs` | Onde assistir Duna em BR e US. |
| `dunaProvidersResponse` | Resposta do TMDB com BR, US e PT (PT sem serviços). |

## Testes de widget com tradução

Monte o `MaterialApp` com `AppLocalizations.localizationsDelegates`,
`AppLocalizations.supportedLocales` e um `locale` fixo. Com `locale: pt`, o
botão de voltar tem o tooltip "Voltar": `tester.pageBack()` procura "Back" e
falha. Use `tester.tap(find.byType(BackButton))`.
