# Como verificar uma mudança no app de verdade

Os testes usam fakes. Para ver rede, TMDB e WebView reais, rode o app.

## Na web

```sh
flutter build web
cd build/web && python3 -m http.server 8791 --bind 127.0.0.1
```

Abra <http://127.0.0.1:8791>. Confira o título da aba ("App Filmes"): outra
aplicação pode estar na porta.

## Ver o app em outro idioma

O app segue o idioma do navegador. No Linux, rode o navegador (ou o
`flutter run`) com a variável `LANGUAGE`:

```sh
LANGUAGE=en_US flutter run -d chrome
```

A interface e o conteúdo do TMDB mudam juntos. A região dos serviços de
streaming segue o país do idioma (`en_US` → `US`).

No Android, troque o idioma do sistema e reabra o app.

## Ver a tela de detalhes inteira no navegador

O player do YouTube é um iframe e captura a roda do mouse: rolar com o
cursor sobre ele não move a página. Use uma janela alta (por exemplo,
1100×1700), para a tela caber sem rolagem.

## O que conferir

- Textos no idioma certo, incluindo números (`8,4` em pt, `8.4` em en).
- Valores do TMDB podem mudar entre idiomas: a duração de um mesmo filme às
  vezes difere entre `pt-BR` e `en-US`.
- Console do navegador sem erros. Um erro de CORS em `i3.ytimg.com`
  indica que a miniatura do trailer voltou a ser WebP (veja
  [Plataformas](../explicacao/plataformas.md#o-que-muda-na-web)).
