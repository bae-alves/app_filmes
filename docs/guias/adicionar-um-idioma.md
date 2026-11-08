# Como adicionar um idioma

Exemplo com espanhol (`es`). Troque pelo seu código de idioma.

## 1. Crie o arquivo de tradução

Copie o inglês e troque o `@@locale`:

```sh
cp lib/l10n/app_en.arb lib/l10n/app_es.arb
```

```json
{
  "@@locale": "es",
  ...
}
```

Traduza **todas** as chaves. Chave que falta aparece em português (o idioma
modelo), não em inglês. Para listar as que faltam, adicione ao `l10n.yaml`:

```yaml
untranslated-messages-file: build/untranslated.json
```

## 2. Gere o código

```sh
flutter gen-l10n
```

`AppLocalizations.supportedLocales` passa a incluir `Locale('es')` sozinho.
Não há lista de idiomas para editar no `main.dart`.

## 3. Peça o conteúdo do TMDB no novo idioma

Em `lib/data/services/tmdb_rest_client.dart`, adicione a entrada em
`tmdbLanguages`:

```dart
const Map<String, String> tmdbLanguages = {
  'pt': 'pt-BR',
  'en': 'en-US',
  'es': 'es-ES',
};
```

Sem a entrada, a interface aparece em espanhol e o conteúdo (título,
sinopse, gêneros) em inglês.

## 4. Teste

Em `test/utils/user_locale_test.dart`:

```dart
test('espanhol pede conteúdo em es-ES', () {
  expect(tmdbLanguageFor(const [Locale('es')]), 'es-ES');
});
```

Nos testes de widget, use `locale: const Locale('es')`. O teste
`idioma não suportado cai para en-US` deixa de valer para `es`: troque o
exemplo por um idioma que o app não suporta.

## 5. Veja no app

No Linux:

```sh
LANGUAGE=es_ES flutter run -d chrome
```

## Para remover um idioma

Apague o `.arb` **e** o arquivo gerado `lib/l10n/app_localizations_<idioma>.dart`.
O `flutter gen-l10n` não apaga arquivos antigos.

## Veja também

- [Referência: configuração](../referencia/configuracao.md)
- [Explicação: internacionalização](../explicacao/internacionalizacao.md)
