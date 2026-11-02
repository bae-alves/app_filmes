# app_filmes

Aplicativo Flutter que lista os filmes populares do
[TMDB](https://developer.themoviedb.org/docs/getting-started) e abre uma tela
de detalhes com o trailer, as informações de cada filme e onde assisti-lo.
Os filmes podem ser salvos numa lista de favoritos e avaliados com nota e
humor, tudo guardado no aparelho.
Roda em Android e na web, em português e em inglês.

## Começo rápido

```sh
cp .env.example .env          # preencha TMDB_READ e TMDB_API_KEY
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

Detalhes em [Configurar o ambiente](docs/guias/configurar-o-ambiente.md).

## Testes

```sh
flutter analyze
flutter test
```

Os testes rodam offline, com fakes no lugar do TMDB. Veja a
[referência de testes](docs/referencia/testes.md).

## Antes do push

O hook [`.githooks/pre-push`](.githooks/pre-push) roda `dart format`,
`flutter analyze` e `flutter test`, e bloqueia o push se o formatador mudar
algum arquivo, se a análise achar problemas ou se algum teste falhar. Depois
de uma formatação, faça commit dela e repita o push. Ative o hook uma vez por
clone:

```sh
git config core.hooksPath .githooks
```

## CI

O GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml))
roda em cada pull request para a `main`, em cada push na `main` e sob demanda
(aba Actions → CI → Run workflow).

| Etapa | O que faz |
| --- | --- |
| Lint | `dart format` (só confere) e `flutter analyze` |
| Testes | `flutter test` |
| Build web | `flutter build web --release`, guardado como artefato `web` |
| Build Android | `flutter build apk --release`, guardado como artefato `apk` |
| Smoke web | abre o build num Chrome headless e fecha |
| Smoke Android | instala o APK num emulador, abre o app e fecha |

Lint e testes rodam em paralelo; os builds só começam se os dois passarem, e
cada smoke usa o build da sua plataforma. O CI grava um `.env` com um token
falso: os smoke tests provam que o app abre sem erro, não que o TMDB responde.
O hook, o CI e a proteção da `main` estão explicados em [`dev-ops.md`](dev-ops.md).

Para rodar os smoke tests na sua máquina:

```sh
npm ci --prefix tool/smoke
flutter build web && node tool/smoke/web_smoke.mjs build/web
flutter build apk && tool/smoke/android_smoke.sh   # com um aparelho no adb
```

## Organização do trabalho

- **Tarefas:** cada tarefa é um ticket do Jira com a chave `MOVIEAI`. O
  commit começa pela chave do ticket, como em `MOVIEAI-22: avalia filmes…`.
- **Branches:** cada integrante trabalha numa branch própria por sprint,
  `sprint-<n>-<integrante>` (por exemplo, `sprint-2-ber`).
- **`main`:** é a linha principal. As branches de sprint entram nela por pull
  request, que só entra com o CI verde e a aprovação de outro integrante.

## Documentação

Toda a documentação está em [`docs/`](docs/README.md):

- **Tutorial:** [crie um widget traduzido](docs/tutoriais/criar-um-widget-traduzido.md)
- **Guias:** configurar o ambiente, adicionar textos, idiomas e endpoints,
  verificar no app
- **Referência:** configuração, repositório, widgets, testes
- **Explicação:** [arquitetura](docs/explicacao/arquitetura.md),
  plataformas, [internacionalização](docs/explicacao/internacionalizacao.md),
  onde assistir, [favoritos](docs/explicacao/favoritos.md),
  [avaliações](docs/explicacao/avaliacoes.md)

## Estrutura

```
lib/
├── data/
│   ├── api_models/     # modelos do JSON do TMDB (json_serializable)
│   ├── repositories/   # MoviesRepository, FavoritesRepository e RatingsRepository (contratos + implementações)
│   └── services/       # TmdbRestClient (retrofit), Dio e o banco SQLite (AppDatabase)
├── l10n/               # textos traduzidos (.arb) e AppLocalizations gerado
├── ui/
│   ├── view/           # telas e widgets
│   └── view_model/     # estado das telas (ChangeNotifier)
├── utils/              # Result, Env, localidade do usuário, formatadores, URLs de imagem do TMDB
└── main.dart           # composição das dependências
docs/                   # documentação (Diátaxis)
test/                   # testes e fakes
```
