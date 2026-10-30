# Arquitetura

O app segue a [arquitetura recomendada pelo Flutter](https://docs.flutter.dev/app-architecture):
MVVM, com uma camada de UI e uma camada de dados.

```
UI layer                         Data layer
┌──────────┐   ┌───────────┐   ┌──────────────┐   ┌──────────┐   ┌──────────┐
│   View   │◄─►│ ViewModel │◄─►│  Repository  │◄─►│ Service  │◄─►│   TMDB   │
└──────────┘   └───────────┘   └──────────────┘   └──────────┘   └──────────┘
   widgets       estado da        fonte única        retrofit         HTTP
                    tela          da verdade
```

## O papel de cada camada

**Service** (`TmdbRestClient`) descreve os endpoints: verbo, caminho,
parâmetros e tipo de retorno. Não tem estado nem regra. O retrofit gera a
implementação.

**Repositório** (`MoviesRepository`) é a fonte única dos dados de filmes.
Nele mora tudo que não é requisição nem estado de tela: cache, tradução de
falhas em `Result`, a escolha de qual vídeo é "o trailer" e de qual país vale
em "onde assistir". Os caches vivem em memória, menos o de detalhes, que fica
salvo no aparelho por 24h para a tela abrir mesmo com a API instável.
`FavoritesRepository` faz o mesmo papel para a lista de favoritos, e
`RatingsRepository` para as avaliações, ambos em SQLite no aparelho (veja
[Favoritos](favoritos.md) e [Avaliações](avaliacoes.md)).

**View model** (`ChangeNotifier`) guarda o estado de uma tela e expõe
comandos (`load`, `search`). Não conhece widgets nem `Navigator`. Avisa a view
com `notifyListeners`.

**View** desenha o estado (`UI = f(state)`) e repassa os eventos à view model.
Navegação simples também fica na view.

## Por que erros viram valores

O repositório nunca lança exceção: devolve `Result`, que é `Ok` ou `Error`.
Como `Result` é `sealed`, o `switch` sem um dos casos não compila. Quem chama
é obrigado a decidir o que fazer com a falha.

Algumas falhas não impedem a tela de funcionar. Um filme sem trailer, ou sem
dados de onde assistir, ainda tem informações para mostrar. A
`MovieDetailsViewModel` trata essas falhas como "não há", e só a falha dos
detalhes vira erro na tela.

## Por que injetar tudo

Nenhuma camada cria a de baixo. O `main.dart` monta service → repositório →
view model → view, e nada mais faz isso. Valores que vêm do ambiente, como o
idioma do conteúdo e a região do usuário, também entram por ali.

Isso deixa cada peça substituível. Os testes trocam o service por
`FakeTmdbRestClient` e o repositório por `FakeMoviesRepository`, e rodam sem
rede. A tela de detalhes recebe o player como uma função
(`TrailerPlayerBuilder`) porque o player real precisa de WebView, que não
existe no ambiente de teste.

## Por que widgets "burros"

`MovieCard` e `WatchProvidersSection` recebem dados prontos e callbacks. Não
sabem de onde o filme veio nem o que acontece no toque. Por isso a
`WatchProvidersSection` serve hoje à tela de detalhes e poderá servir aos
cards de recomendação da IA sem mudar.

## Veja também

- [Referência: repositório](../referencia/repositorio.md)
- [Como adicionar um endpoint do TMDB](../guias/adicionar-um-endpoint-do-tmdb.md)
