# Referência: testes

```sh
flutter test      # suíte inteira, offline
flutter analyze   # análise estática
```

## Arquivos

| Arquivo | Testes | O que verifica |
| --- | --- | --- |
| `test/utils/formatters_test.dart` | 10 | Ano, duração e nota, em pt e en. |
| `test/utils/user_locale_test.dart` | 4 | Idioma do TMDB a partir dos idiomas do dispositivo. |
| `test/data/repositories/movies_repository_remote_test.dart` | 20 | Cache, erros HTTP e de rede, escolha do trailer, onde assistir por região, idioma enviado ao TMDB. |
| `test/ui/view_model/home_view_model_test.dart` | 5 | Estados de carregamento e erro da home. |
| `test/ui/view_model/movie_details_view_model_test.dart` | 8 | Detalhes, trailer e onde assistir; falhas toleradas. |
| `test/ui/view/home_to_details_navigation_test.dart` | 11 | Navegação da home aos detalhes, em pt e en. |
| `test/ui/view/watch_providers_section_test.dart` | 5 | Grupos, ordem, indisponível, modo compacto, pt e en. |

## Fakes

Em `test/fakes/`. Substituem a rede; os testes rodam offline.

### `FakeTmdbRestClient`

Substitui o service nos testes do repositório.

| Membro | Descrição |
| --- | --- |
| `popularPage`, `details`, `videosByLanguage`, `watchProviders` | Respostas devolvidas. |
| `statusCode` | Status HTTP de todas as respostas (padrão 200). |
| `errorToThrow` | Se definido, toda chamada lança. |
| `popularCallCount`, `detailsCallCount`, `watchProvidersCallCount` | Contagem de chamadas. |
| `requestedLanguages` | Idiomas recebidos pelos endpoints com `language` obrigatório. |
| `requestedVideoLanguages` | Idiomas pedidos a `getMovieVideos`. |

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
| `dunaId`, `dunaMovie`, `dunaDetails`, `dunaTrailer` | Filme completo, com trailer. |
| `matrixId`, `matrixMovie`, `matrixDetails` | Filme sem trailer e sem campos opcionais. |
| `netflix`, `maxStreaming`, `appleTv` | Serviços de streaming. |
| `dunaProvidersBr`, `dunaProvidersUs` | Onde assistir Duna em BR e US. |
| `dunaProvidersResponse` | Resposta do TMDB com BR, US e PT (PT sem serviços). |

## Testes de widget com tradução

Monte o `MaterialApp` com `AppLocalizations.localizationsDelegates`,
`AppLocalizations.supportedLocales` e um `locale` fixo. Com `locale: pt`, o
botão de voltar tem o tooltip "Voltar": `tester.pageBack()` procura "Back" e
falha. Use `tester.tap(find.byType(BackButton))`.
