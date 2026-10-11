# Como verificar uma mudança no app de verdade

Os testes usam fakes. Para ver rede, TMDB e WebView reais, rode o app.

## Pelo Claude Code

Dois skills do repositório fazem build, rodam e tiram screenshots:

- `/run-app-filmes`: build web servida localmente, num Chromium headless;
- `/run-app-filmes-avd`: emulador Android.

As instruções completas ficam em `.claude/skills/*/SKILL.md`.

## Na mão, na web

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

## Ver a tela de detalhes inteira no navegador headless

O player do YouTube é um iframe e captura a roda do mouse: rolar com o
cursor sobre ele não move a página. Use uma janela alta, para a tela caber
sem rolagem:

```sh
VIEWPORT=1100x1700 node .claude/skills/run-app-filmes/driver.mjs
```

## O que conferir

- Textos no idioma certo, incluindo números (`8,4` em pt, `8.4` em en).
- Valores do TMDB podem mudar entre idiomas: a duração de um mesmo filme às
  vezes difere entre `pt-BR` e `en-US`.
- `errors` no driver: o erro de CORS em `i3.ytimg.com` é esperado.
