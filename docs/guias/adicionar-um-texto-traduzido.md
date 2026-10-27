# Como adicionar um texto traduzido

Todo texto que o usuário lê sai de `lib/l10n/`. Nunca escreva
`Text('...')` com texto fixo.

## 1. Escolha o nome da chave

Use camelCase com o nome da tela na frente: `homeEmpty`, `detailsLoadError`.
Textos usados em várias telas não levam prefixo: `retry`, `untitled`.

Antes de criar, procure se a chave já existe em `lib/l10n/app_pt.arb`.

## 2. Adicione a chave no português

`lib/l10n/app_pt.arb` é o modelo. Toda chave nasce nele, com a descrição:

```json
  "homeEmpty": "Nenhum filme encontrado no momento.",
  "@homeEmpty": {
    "description": "Aviso da tela inicial quando a lista volta vazia."
  },
```

Escreva na descrição onde o texto aparece. É o que o tradutor lê.

## 3. Traduza nos outros idiomas

Em `lib/l10n/app_en.arb` (e em cada outro `app_<idioma>.arb`), só a chave:

```json
  "homeEmpty": "No movies found right now.",
```

Chave que falta num idioma aparece **em português**, não em inglês.

## 4. Gere o código

```sh
flutter gen-l10n
```

## 5. Use no widget

```dart
import '../../l10n/app_localizations.dart'; // ajuste o caminho

Text(AppLocalizations.of(context).homeEmpty)
```

Se o widget era `const`, tire o `const`: o texto agora depende do contexto.

## 6. Teste nos dois idiomas

Monte o `MaterialApp` do teste com os delegates e o idioma:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: ...,
)
```

Sem os delegates, `AppLocalizations.of(context)` falha. Para testar uma função
sem widget, use `lookupAppLocalizations(const Locale('en'))`.

## Variações

### Texto com valor dentro

```json
  "runtimeHours": "{hours}h",
  "@runtimeHours": {
    "description": "Duração exata em horas (ex.: 2h).",
    "placeholders": {
      "hours": {"type": "int"}
    }
  },
```

Uso: `l10n.runtimeHours(2)`.

### Número com separador de milhar

Adicione `"format": "decimalPattern"` ao placeholder. O separador segue o
idioma: `5.000` em português, `5,000` em inglês.

### Singular e plural

```json
  "voteCount": "{count, plural, =0{Ainda sem votos} =1{Baseado em 1 voto} other{Baseado em {count} votos}}",
```

O placeholder `count` precisa ser `int` (ou `num`).

### Número fora de um texto

Para um número sozinho, use o `intl` com o idioma do contexto, como faz
`formatRating` em `lib/utils/formatters.dart`:

```dart
NumberFormat.decimalPatternDigits(
  locale: Localizations.localeOf(context).toString(),
  decimalDigits: 1,
).format(7.84); // "7,8" em pt, "7.8" em en
```

### Mensagem de erro

Não mostre `error.toString()`: a mensagem vem do repositório, em português e
técnica. Crie uma chave para a tela (`homeLoadError`) e mande o erro para o
log com `debugPrint` na view model.

## Veja também

- [Tutorial: crie um widget traduzido](../tutoriais/criar-um-widget-traduzido.md)
- [Referência: configuração](../referencia/configuracao.md#traduções)
- [Explicação: internacionalização](../explicacao/internacionalizacao.md)
