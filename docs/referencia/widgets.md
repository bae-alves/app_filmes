# Referência: telas e widgets

Todos exigem os delegates de `AppLocalizations` no `MaterialApp`.

## `HomePage`

`lib/ui/view/home_page.dart`. Lista de filmes, pesquisa e filtro por gênero.

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `viewModel` | `HomeViewModel` | — | Estado e comandos. |
| `favoritesViewModel` | `FavoritesViewModel` | — | Lista de favoritos. O coração da barra abre a `FavoritesPage`. |
| `detailsViewModelFactory` | `MovieDetailsViewModel Function(int movieId)` | — | Cria a view model da tela de detalhes. |
| `trailerPlayerBuilder` | `TrailerPlayerBuilder` | `defaultTrailerPlayerBuilder` | Repassado à tela de detalhes. |

## `MovieDetailsPage`

`lib/ui/view/movie_details_page.dart`. Trailer, informações e onde assistir.
A fileira do elenco mostra os 10 primeiros. Com mais gente, o botão "Ver todos"
abre a lista completa.

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `viewModel` | `MovieDetailsViewModel` | — | Estado e comandos. Chama `load()` no `initState`. |
| `favoritesViewModel` | `FavoritesViewModel` | — | Liga e desliga o coração da barra, que aparece quando os detalhes carregam. |
| `fallbackTitle` | `String?` | `null` | Título da barra enquanto os detalhes carregam. |
| `trailerPlayerBuilder` | `TrailerPlayerBuilder` | `defaultTrailerPlayerBuilder` | Constrói o player. |

| Membro estático | Valor |
| --- | --- |
| `routeName` | `/movie-details` |
| `trailerKey` | `Key('movie-details-trailer')`: bloco do player. |
| `emptyTrailerKey` | `Key('movie-details-trailer-empty')`: aviso de filme sem trailer. |
| `favoriteButtonKey` | `Key('movie-details-favorite')`: coração da barra. |
| `route({viewModel, favoritesViewModel, fallbackTitle, trailerPlayerBuilder})` | `Route` até a tela, usada pela home e pelos favoritos. |

## `FavoritesPage`

`lib/ui/view/favorites_page.dart`. Lista de favoritos, do mais recente ao
mais antigo, em `MovieCard`s. Tocar num cartão abre os detalhes. Para tirar
um filme da lista, o usuário desfavorita na tela de detalhes; ao voltar, a
lista já está atualizada. Chama `load()` no `initState`. Mostra um aviso
quando a lista está vazia, e erro com "Tentar novamente" quando a leitura
falha.

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `viewModel` | `FavoritesViewModel` | — | A mesma instância da home e dos detalhes. |
| `detailsViewModelFactory` | `MovieDetailsViewModel Function(int movieId)` | — | Cria a view model da tela de detalhes. |
| `trailerPlayerBuilder` | `TrailerPlayerBuilder` | `defaultTrailerPlayerBuilder` | Repassado à tela de detalhes. |

## `MovieCard`

`lib/ui/view/widgets/movie_card.dart`. Cartão de um filme na lista.

| Parâmetro | Tipo | Descrição |
| --- | --- | --- |
| `movie` | `Movie` | Filme exibido. |
| `onTap` | `VoidCallback` | Chamado no toque. |

A `HomePage` e a `FavoritesPage` dão a cada cartão a chave `ValueKey(movie.id)`.

## `WatchProvidersSection`

`lib/ui/view/widgets/watch_providers_section.dart`. Onde assistir o filme.

| Parâmetro | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `region` | `WatchProviderRegion?` | — | Serviços no país do usuário. `null` mostra o aviso de indisponível. |
| `compact` | `bool` | `false` | Só os logos (28 px), cada serviço uma vez, sem rótulos, botão e crédito. Para cards. |

| Membro estático | Valor |
| --- | --- |
| `unavailableKey` | `Key('watch-providers-unavailable')` |
| `linkKey` | `Key('watch-providers-link')` |

Modo completo, em ordem: grupos Assinatura (`flatrate`), Grátis (`free` +
`ads`), Alugar (`rent`) e Comprar (`buy`), cada um ordenado por
`displayPriority` e omitido se vazio; botão "Ver onde assistir" (se houver
`link`); crédito "Fonte: JustWatch". Logos de 40 px com o nome no tooltip;
tocar num logo abre o mesmo `link` do botão. No modo `compact`, os logos não
respondem ao toque.

## `TrailerPlayer` e `TrailerPlayerBuilder`

`lib/ui/view/widgets/trailer_player.dart`.

- `TrailerPlayerBuilder`: `Widget Function(BuildContext context, String youtubeKey)`.
- `defaultTrailerPlayerBuilder`: devolve `TrailerPlayer(youtubeKey: ...)`.
- `TrailerPlayer`: player do YouTube (`youtube_player_iframe`), sem
  reprodução automática, com botão de tela cheia e os controles do próprio
  YouTube. Toca no máximo `TrailerPlayer.maxDuration` (2 minutos): ao passar
  disso, o vídeo para e volta para o início.

Nos testes, passe um builder que devolve um `Text` com a chave: o player real
precisa de WebView.

## Formatadores

`lib/utils/formatters.dart`.

| Função | Exemplo pt | Exemplo en | `null` quando |
| --- | --- | --- | --- |
| `formatReleaseYear(date)` | `2024` | `2024` | Data ausente ou inválida |
| `formatRuntime(minutes, l10n)` | `2h 46min`, `2h`, `45min` | `2h 46m`, `2h`, `45m` | `null` ou ≤ 0 |
| `formatRating(average, locale)` | `8,2` | `8.2` | `null` ou ≤ 0 |
