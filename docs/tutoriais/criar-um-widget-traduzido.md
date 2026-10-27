# Tutorial: crie um widget traduzido

Neste tutorial você cria o `VoteCountLabel`, um widget que mostra quantas
pessoas avaliaram o filme:

| Idioma | 5000 votos | 1 voto | 0 votos |
| --- | --- | --- | --- |
| Português | Baseado em 5.000 votos | Baseado em 1 voto | Ainda sem votos |
| Inglês | Based on 5,000 votes | Based on 1 vote | No votes yet |

No caminho, você vai escrever o widget, testá-lo, mover o texto para os
arquivos de tradução (com número formatado e plural) e vê-lo no app nos dois
idiomas. Leva uns 20 minutos.

O widget é um exercício: no fim, você decide se descarta ou mantém.

## Antes de começar

- Siga [Configurar o ambiente](../guias/configurar-o-ambiente.md) até o app
  rodar.
- Confirme que a suíte passa:

  ```sh
  flutter test
  ```

  A última linha deve terminar em `All tests passed!`.

## 1. Crie o widget com o texto fixo

Crie o arquivo `lib/ui/view/widgets/vote_count_label.dart`:

```dart
import 'package:flutter/material.dart';

/// Mostra quantas pessoas avaliaram o filme no TMDB.
class VoteCountLabel extends StatelessWidget {
  const VoteCountLabel({super.key, required this.count});

  /// Total de votos do filme.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Baseado em $count votos',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
```

## 2. Coloque o widget na tela de detalhes

Em `lib/ui/view/movie_details_page.dart`, importe o widget junto dos outros
widgets:

```dart
import 'widgets/vote_count_label.dart';
```

Logo abaixo da linha com `_MetadataRow(...)`, adicione:

```dart
              _MetadataRow(year: year, runtime: runtime, rating: rating),
              if (details.voteCount != null) ...[
                const SizedBox(height: 4),
                VoteCountLabel(count: details.voteCount!),
              ],
```

Rode o app e abra um filme:

```sh
flutter run -d chrome
```

Abaixo da nota aparece "Baseado em", o número de votos sem separador de
milhar, e "votos". Repare em dois problemas: o número está sem ponto, e um
filme com um voto apareceria como "1 votos". Você vai corrigir os dois.

## 3. Escreva o teste e veja-o falhar

Crie `test/ui/view/vote_count_label_test.dart`:

```dart
import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/widgets/vote_count_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildLabel(int count, {Locale locale = const Locale('pt')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: VoteCountLabel(count: count)),
    );
  }

  testWidgets('mostra o total de votos com separador de milhar',
      (tester) async {
    await tester.pumpWidget(buildLabel(5000));
    expect(find.text('Baseado em 5.000 votos'), findsOneWidget);
  });

  testWidgets('usa o singular para um voto', (tester) async {
    await tester.pumpWidget(buildLabel(1));
    expect(find.text('Baseado em 1 voto'), findsOneWidget);
  });

  testWidgets('avisa quando o filme ainda não tem votos', (tester) async {
    await tester.pumpWidget(buildLabel(0));
    expect(find.text('Ainda sem votos'), findsOneWidget);
  });
}
```

Rode só esse arquivo:

```sh
flutter test test/ui/view/vote_count_label_test.dart
```

Os três testes falham. Entre as mensagens, você vê:

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Baseado em 5.000 votos": []>
...
00:01 +0 -3: Some tests failed.
```

## 4. Crie a chave de tradução em português

Abra `lib/l10n/app_pt.arb` e adicione a chave `voteCount` (no meio do arquivo,
depois de qualquer outra chave — lembre da vírgula):

```json
  "voteCount": "{count, plural, =0{Ainda sem votos} =1{Baseado em 1 voto} other{Baseado em {count} votos}}",
  "@voteCount": {
    "description": "Quantas pessoas avaliaram o filme no TMDB. Aparece abaixo da nota, na tela de detalhes.",
    "placeholders": {
      "count": {"type": "int", "format": "decimalPattern"}
    }
  },
```

## 5. Traduza para o inglês

Em `lib/l10n/app_en.arb`, adicione a mesma chave, sem o bloco `@voteCount`:

```json
  "voteCount": "{count, plural, =0{No votes yet} =1{Based on 1 vote} other{Based on {count} votes}}",
```

## 6. Use a tradução no widget

Em `vote_count_label.dart`, importe as traduções:

```dart
import '../../../l10n/app_localizations.dart';
```

E troque o texto fixo pela chave:

```dart
    return Text(
      AppLocalizations.of(context).voteCount(count),
      style: Theme.of(context).textTheme.bodySmall,
    );
```

Rode o teste:

```sh
flutter test test/ui/view/vote_count_label_test.dart
```

Ele não compila:

```
lib/ui/view/widgets/vote_count_label.dart:15:36: Error: The method 'voteCount' isn't defined for the type 'AppLocalizations'.
```

O `flutter test` não lê os arquivos `.arb`. Gere o código das traduções:

```sh
flutter gen-l10n
```

Ele avisa que usou o `l10n.yaml`:

```
Because l10n.yaml exists, the options defined there will be used instead.
```

Rode o teste de novo:

```sh
flutter test test/ui/view/vote_count_label_test.dart
```

```
00:00 +3: All tests passed!
```

## 7. Teste em inglês

No fim de `vote_count_label_test.dart`, antes do último `}`, adicione:

```dart
  testWidgets('em inglês, usa vírgula no milhar e o plural do inglês',
      (tester) async {
    await tester.pumpWidget(buildLabel(5000, locale: const Locale('en')));
    expect(find.text('Based on 5,000 votes'), findsOneWidget);

    await tester.pumpWidget(buildLabel(1, locale: const Locale('en')));
    expect(find.text('Based on 1 vote'), findsOneWidget);
  });
```

Rode:

```sh
flutter test test/ui/view/vote_count_label_test.dart
```

```
00:00 +4: All tests passed!
```

Rode também a suíte inteira e a análise, para ver que nada quebrou:

```sh
flutter analyze
flutter test
```

## 8. Veja o widget no app, nos dois idiomas

Rode o app de novo e abra um filme:

```sh
flutter run -d chrome
```

Agora o número tem ponto no milhar: "Baseado em 4.945 votos", por exemplo.

Para ver em inglês no Linux, rode com o navegador em inglês:

```sh
LANGUAGE=en_US flutter run -d chrome
```

Em outro sistema, mude o idioma do navegador nas configurações dele. A tela
inteira aparece em inglês, e o widget mostra "Based on 4,945 votes". Título e
sinopse do filme também vêm em inglês: o app pede o conteúdo do TMDB no mesmo
idioma da interface.

## O que você fez

- Criou um widget que só recebe dados e não conhece repositório.
- Escreveu o teste antes de traduzir, e viu ele falhar.
- Criou uma chave de tradução com placeholder `int`, formato de número e
  plural.
- Gerou o código com `flutter gen-l10n`.
- Testou o widget nos dois idiomas, sem abrir o app.

## Próximos passos

- Para descartar o exercício:

  ```sh
  rm lib/ui/view/widgets/vote_count_label.dart test/ui/view/vote_count_label_test.dart
  git restore lib/l10n lib/ui/view/movie_details_page.dart
  ```

- Para manter, faça o commit dos arquivos novos e dos arquivos gerados em
  `lib/l10n/`.
- Para o dia a dia, use o guia
  [Adicionar um texto traduzido](../guias/adicionar-um-texto-traduzido.md).
- Para entender por que idioma, região e conteúdo são escolhidos assim, leia
  [Internacionalização](../explicacao/internacionalizacao.md).
