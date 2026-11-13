# app_filmes

Aplicativo Flutter que lista os filmes populares do
[TMDB](https://developer.themoviedb.org/docs/getting-started), exibe detalhes com
trailer, informações de elenco e onde assisti-los.
Conta com **autenticação de usuário (Email/Senha e Supabase)**, **assistente inteligente MovieAI (Google Gemini)**, **onboarding visual de gosto em 3 etapas**, lista de favoritos e avaliações emocionais.
Roda em Android, iOS e na web, em português e em inglês.

## Funcionalidades Principais

- **Filmes Populares e Destaque:** Lista atualizada do TMDB com busca em tempo real e filtro por múltiplos gêneros.
- **Detalhes e Trailer:** Player de vídeo integrado, sinopse, elenco, equipe e disponibilidade em streaming (JustWatch).
- **Autenticação e Perfil:** Cadastro e login por e-mail/senha ou Supabase Auth, com gestão de dados da conta.
- **Onboarding Visual (3 Etapas):** Seleção de gêneros, atores e diretores favoritos na primeira utilização.
- **Assistente MovieAI:** Recomendação generativa via Google Gemini combinando perfil de gosto, histórico de avaliações e contexto do momento.
- **Favoritos e Avaliações:** Salve filmes e dê notas de 1 a 5 estrelas com reações emocionais, com escopo e persistência por usuário.

## Começo rápido

```sh
cp .env.example .env          # preencha TMDB_READ, GEMINI_API_KEY e (opcional) SUPABASE_URL / SUPABASE_ANON_KEY
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

Os testes rodam offline com fakes para TMDB, Gemini e banco SQLite em memória. Veja a [referência de testes](docs/referencia/testes.md).

## Antes do push

O hook [`.githooks/pre-push`](.githooks/pre-push) roda `dart format`,
`flutter analyze` e `flutter test`, e bloqueia o push se houver algum problema.
Ative o hook uma vez por clone:

```sh
git config core.hooksPath .githooks
```

## CI

O GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml))
roda em cada pull request para a `main`, em cada push na `main` e sob demanda.

| Etapa | O que faz |
| --- | --- |
| Lint | `dart format` (só confere) e `flutter analyze` |
| Testes | `flutter test` |
| Build web | `flutter build web --release`, guardado como artefato `web` |
| Build Android | `flutter build apk --release`, guardado como artefato `apk` |
| Smoke web | abre o build num Chrome headless e fecha |
| Smoke Android | instala o APK num emulador, abre o app e fecha |

## Organização do trabalho

- **Tarefas:** cada tarefa é um ticket do Jira com a chave `MOVIEAI`.
- **Branches:** cada integrante trabalha numa branch própria por sprint, `sprint-<n>-<integrante>`.
- **`main`:** linha principal protegida por PR e CI.

## Estrutura

```
lib/
├── data/
│   ├── api_models/     # modelos JSON do TMDB (json_serializable)
│   ├── models/         # UserAccount, UserOnboardingPreferences, RecommendationContext
│   ├── repositories/   # MoviesRepository, FavoritesRepository, RatingsRepository, AuthRepository e OnboardingRepository
│   └── services/       # TmdbRestClient (retrofit), GeminiService, RecommendationContextService, AppDatabase (SQLite)
├── l10n/               # textos traduzidos (.arb) e AppLocalizations gerado
├── ui/
│   ├── view/           # HomePage, ChatPage, FavoritesPage, ProfilePage, LoginPage, SignUpPage, OnboardingPage
│   └── view_model/     # HomeViewModel, ChatViewModel, FavoritesViewModel, AuthViewModel, OnboardingViewModel
├── utils/              # Result, Env, localidade do usuário, formatadores, URLs de imagem
└── main.dart           # composição das dependências
docs/                   # documentação (Diátaxis)
test/                   # testes unitários e fakes
```
