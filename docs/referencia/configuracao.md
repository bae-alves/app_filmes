# Referência: configuração

## Variáveis de ambiente (`.env`)

Lidas por `Env` (`lib/utils/env.dart`) com `flutter_dotenv`. O `.env` é um
asset declarado no `pubspec.yaml` e fica fora do git. O modelo é o
`.env.example`.

| Variável | Uso | Obrigatória |
| --- | --- | --- |
| `TMDB_READ` | API Read Access Token (v4), enviado em `Authorization: Bearer`. | Sim. Sem ela o app lança `StateError` no início. |
| `TMDB_API_KEY` | API Key (v3), para ferramentas que usam `api_key`. O app não a lê hoje. | Não |

Na build web, o `.env` vai dentro do bundle e qualquer visitante consegue
lê-lo.

## Constantes do TMDB

Em `lib/data/services/tmdb_rest_client.dart`.

| Constante | Valor | Uso |
| --- | --- | --- |
| `tmdbBaseUrl` | `https://api.themoviedb.org/3` | URL base do `TmdbRestClient`. |
| `tmdbLanguages` | `{'pt': 'pt-BR', 'en': 'en-US'}` | Idioma do TMDB para cada idioma da interface. |
| `tmdbFallbackLanguage` | `en-US` | Idioma do conteúdo quando a interface está num idioma fora de `tmdbLanguages`; segunda tentativa de trailer. |
| `tmdbFallbackWatchRegion` | `BR` | País de "onde assistir" quando o dispositivo não informa país. |

Rede (`createTmdbDio`, `lib/data/services/tmdb_dio.dart`): timeouts de
conexão e de leitura de 15 s; log das requisições só em modo debug.

## Localidade do usuário

Em `lib/utils/user_locale.dart`. Lidas uma vez, no `main.dart`.

| Função | Devolve | Origem |
| --- | --- | --- |
| `currentWatchRegion()` | País ISO 3166-1 (`BR`, `US`) | País da localidade principal do dispositivo; `tmdbFallbackWatchRegion` se não houver. |
| `currentTmdbLanguage()` | Idioma do TMDB (`pt-BR`, `en-US`) | `tmdbLanguageFor` com os idiomas preferidos do dispositivo. |
| `tmdbLanguageFor(locales)` | Idioma do TMDB | Resolve `locales` contra `AppLocalizations.supportedLocales` com `basicLocaleListResolution` e mapeia por `tmdbLanguages`. |

## Traduções

### `l10n.yaml`

| Opção | Valor | Efeito |
| --- | --- | --- |
| `arb-dir` | `lib/l10n` | Pasta dos `.arb` e do código gerado. |
| `template-arb-file` | `app_pt.arb` | Arquivo modelo: define as chaves, as descrições e os placeholders. |
| `output-localization-file` | `app_localizations.dart` | Nome do arquivo gerado com `AppLocalizations`. |
| `nullable-getter` | `false` | `AppLocalizations.of(context)` não é anulável. |

### Arquivos

| Arquivo | Conteúdo |
| --- | --- |
| `lib/l10n/app_pt.arb` | Modelo, em português do Brasil. Vale para qualquer `pt`. |
| `lib/l10n/app_en.arb` | Inglês. Vale para qualquer `en`. |
| `lib/l10n/app_localizations*.dart` | Gerados. Não edite; versionados no git. |

### Idiomas suportados

`AppLocalizations.supportedLocales`, em ordem alfabética: `en`, `pt`. Um
dispositivo em outro idioma recebe o primeiro da lista, `en`.

### Geração

| Comando | Gera as traduções? |
| --- | --- |
| `flutter pub get` | Sim |
| `flutter run`, `flutter build` | Sim |
| `flutter gen-l10n` | Sim |
| `flutter test` | Não |

## `pubspec.yaml`

| Entrada | Por quê |
| --- | --- |
| `flutter: generate: true` | Liga o gen-l10n. |
| `flutter_localizations` (SDK) | Traduções dos widgets do Material (ex.: "Voltar"). |
| `intl: 0.20.2` | Fixado pelo `flutter_localizations` do SDK; sem `^`. |
| `lucide_icons_flutter` | Ícones da interface nas partes novas. |
| `url_launcher` | Abre a página "onde assistir" fora do app. |
| `sqflite`, `path` | Banco SQLite dos favoritos e das avaliações no Android. |
| `sqflite_common_ffi_web` | O mesmo banco na web (WebAssembly + IndexedDB). |
| `sqflite_common_ffi` (dev) | O mesmo banco em memória, no `flutter test`. |
| `flutter: assets: - .env` | Empacota as credenciais. |
