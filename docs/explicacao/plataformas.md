# Plataformas

O app roda em **Android e web**. As pastas `linux/`, `macos/`, `windows/` e
`ios/` foram removidas.

## Por que não desktop

O player do trailer (`youtube_player_flutter`) roda dentro de uma WebView, e
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
  miniatura WebP do YouTube não manda, a JPEG manda. Por isso, na web, o
  `TrailerPlayer` usa o player do `youtube_player_iframe` com
  `ThumbnailFormat.jpeg`: o `youtube_player_flutter` não repassa o formato.
