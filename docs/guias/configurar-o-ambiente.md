# Como configurar o ambiente

Do clone ao app rodando na web ou no Android.

## Requisitos

- Flutter estável com Dart 3.12 ou mais novo (`flutter --version`).
- Chrome ou Chromium para a web. Se usar Chromium, aponte
  `CHROME_EXECUTABLE` para ele.
- Android SDK e um emulador, para rodar no Android.
- Uma conta no TMDB.

## 1. Gere as credenciais do TMDB

Em <https://www.themoviedb.org/settings/api>, copie o **API Read Access
Token** (v4) e a **API Key** (v3).

## 2. Crie o `.env`

```sh
cp .env.example .env
```

Preencha:

```env
TMDB_READ=<API Read Access Token (v4)>
TMDB_API_KEY=<API Key (v3)>
```

O `.env` fica fora do git. O app aborta no início se faltar o `TMDB_READ`,
que autentica todas as chamadas.

## 3. Instale as dependências e gere o código

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

O `pub get` também gera as traduções (`lib/l10n/app_localizations*.dart`). O
`build_runner` gera os `*.g.dart` do retrofit e do json_serializable.

Rode de novo:

- `dart run build_runner build` depois de mexer em `lib/data/api_models/` ou
  em `lib/data/services/tmdb_rest_client.dart`;
- `flutter gen-l10n` depois de mexer em `lib/l10n/*.arb`.

Durante o desenvolvimento, `dart run build_runner watch` regenera os
`*.g.dart` sozinho.

## 4. Rode o app

```sh
flutter run -d chrome    # web
flutter devices          # descubra o nome do emulador
flutter run -d <emulador>
```

## 5. Confirme que está tudo certo

```sh
flutter analyze   # "No issues found!"
flutter test      # "All tests passed!"
```

## Problemas comuns

| Sintoma | Correção |
| --- | --- |
| `_$MovieFromJson isn't defined` | Faltou `dart run build_runner build`. |
| `The method 'x' isn't defined for the type 'AppLocalizations'` | Faltou `flutter gen-l10n` depois de editar um `.arb`. |
| Tela branca na web e `404` no console | O `.env` não existe. Crie-o e rode de novo. |
