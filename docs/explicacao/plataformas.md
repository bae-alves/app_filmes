# Plataformas

O app roda em **Android e web**. As pastas `linux/`, `macos/`, `windows/` e
`ios/` foram removidas.

## Por que não desktop

O player do trailer (`youtube_player_iframe`) roda dentro de uma WebView, e
foi essa dependência que tirou o desktop do alvo. Sem trailer, a tela de
detalhes perde a sua função principal.

## Por que não iOS, por ora

Nada no código impede o iOS; ele ficou de fora por ora. Para reativar:

```sh
flutter create --platforms=ios .
```

## O que muda na web

- O `.env` vai dentro do bundle (`build/web/assets/.env`) e qualquer
  visitante consegue lê-lo. É inerente a chamar o TMDB direto do navegador.
- A UI é desenhada num `<canvas>`. Ferramentas que leem o DOM, como o
  Playwright, só enxergam texto depois de ligar a árvore de acessibilidade.
- O idioma e a região vêm do navegador, e não do sistema.
- O Flutter baixa imagens por XHR, então o servidor precisa mandar CORS. A
  miniatura WebP do YouTube não manda, a JPEG manda. Por isso o
  `TrailerPlayer` usa `ThumbnailFormat.jpeg`. É também o motivo de usar o
  `youtube_player_iframe` direto: o `youtube_player_flutter` não repassa o
  formato.
- O banco dos favoritos é SQLite em WebAssembly (`sqflite_common_ffi_web`),
  salvo no IndexedDB. Ele precisa de `web/sqlite3.wasm` e
  `web/sqflite_sw.js`, que estão no git. Ao atualizar o `sqflite_common_ffi_web`
  ou o `sqlite3`, gere os dois de novo com
  `dart run sqflite_common_ffi_web:setup --force`. Como todo armazenamento do
  navegador, o banco é por origem: `localhost:8080` e `localhost:8081` têm
  listas diferentes.
