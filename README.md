# app_filmes

Aplicativo Flutter que lista os filmes populares do
[TMDB](https://developer.themoviedb.org/docs/getting-started) e abre uma tela de
detalhes com o trailer e as informações de cada filme.

## Plataformas

O projeto tem como alvo **Android e web**. As pastas `linux/`, `macos/`,
`windows/` e `ios/` foram removidas. A restrição de desktop vem do player do
trailer (`youtube_player_flutter`), que é baseado em WebView; o iOS foi
descartado por ora, mas nada no código impede reativá-lo com
`flutter create --platforms=ios .`.

Para rodar na web com o Chromium instalado:

```sh
flutter run -d chrome            # usa a variável CHROME_EXECUTABLE
```

## Arquitetura

O projeto segue a arquitetura recomendada pelo Flutter
([app architecture](https://docs.flutter.dev/app-architecture)), no estilo
**MVVM** com separação em camadas:

```
UI layer                         Data layer
┌──────────┐   ┌───────────┐   ┌──────────────┐   ┌──────────┐   ┌──────────┐
│   View   │◄─►│ ViewModel │◄─►│  Repository  │◄─►│ Service  │◄─►│   TMDB   │
└──────────┘   └───────────┘   └──────────────┘   └──────────┘   └──────────┘
   widgets       estado da        fonte única        retrofit         HTTP
                    tela          da verdade
```

Princípios aplicados:

- **Separation of concerns** — cada camada tem uma responsabilidade única.
- **Fonte única da verdade** — o repositório é o único dono dos dados de filmes
  (cache, tratamento de erro e escolha do trailer moram nele).
- **Fluxo unidirecional** — a view dispara comandos, a view model atualiza o
  estado e notifica a view: `UI = f(state)`.
- **Injeção de dependência** — nenhuma camada instancia a de baixo; tudo é
  costurado em `lib/main.dart`, o que torna cada peça substituível nos testes.

### Estrutura de pastas

```
lib/
├── data/
│   ├── api_models/     # modelos que espelham o JSON do TMDB (json_serializable)
│   ├── repositories/   # MoviesRepository (contrato) + implementação remota
│   └── services/       # TmdbRestClient (retrofit) + configuração do Dio
├── ui/
│   ├── view/           # HomePage, MovieDetailsPage e widgets reutilizáveis
│   └── view_model/     # HomeViewModel, MovieDetailsViewModel (ChangeNotifier)
├── utils/              # Result, Env, formatadores e URLs de imagem
└── main.dart           # composição das dependências
```

## Configuração

1. Crie uma conta no TMDB e gere as chaves em
   <https://www.themoviedb.org/settings/api>.
2. Copie `.env.example` para `.env` e preencha:

   ```env
   TMDB_READ=<API Read Access Token (v4)>
   TMDB_API_KEY=<API Key (v3)>
   ```

   O `.env` está no `.gitignore` e é carregado em tempo de execução pelo
   `flutter_dotenv` (declarado como asset no `pubspec.yaml`).

3. Instale as dependências e gere o código do retrofit/json_serializable:

   ```sh
   flutter pub get
   dart run build_runner build
   ```

   Durante o desenvolvimento, `dart run build_runner watch` regenera os
   arquivos `*.g.dart` automaticamente.

4. Rode o app:

   ```sh
   flutter run -d chrome    # web
   flutter run -d emulator  # Android; veja `flutter devices para acertar o nome`
   ```

## Testes

```sh
flutter test
```

A suíte cobre as três camadas:

| Arquivo | O que verifica |
| --- | --- |
| `test/utils/formatters_test.dart` | formatação de ano, duração e nota |
| `test/data/repositories/movies_repository_remote_test.dart` | cache, tratamento de erro HTTP/rede e escolha do trailer (com fallback de idioma) |
| `test/ui/view_model/*_test.dart` | estados de carregamento, erro e notificação das view models |
| `test/ui/view/home_to_details_navigation_test.dart` | o comportamento de navegação da tela inicial para os detalhes |

Os testes usam fakes em memória (`test/fakes/`) no lugar do TMDB, então rodam
offline e de forma determinística.

Para exercitar o app de verdade — rede real, WebView real — há dois skills do
Claude Code neste repositório:

- `/run-app-filmes` — roda a build web num Chromium headless;
- `/run-app-filmes-avd` — sobe o emulador Android, instala o APK e navega pela
  interface.

Ambos tiram screenshots e afirmam sobre o conteúdo da tela.
