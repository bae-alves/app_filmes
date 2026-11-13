import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comportamento coberto por este arquivo:
///
/// > Como usuário, quero trocar entre Início, MovieAI e Favoritos pela barra
/// > inferior, sem perder o que eu estava fazendo em cada aba.
void main() {
  Widget buildApp({Locale locale = const Locale('pt')}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: const AppShell(
      home: Text('aba-inicio'),
      assistant: _Counter(),
      favorites: Text('aba-favoritos'),
    ),
  );

  testWidgets('abre no Início e só monta as outras abas ao visitá-las', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('aba-inicio'), findsOneWidget);
    expect(find.byType(_Counter), findsNothing);
    expect(find.text('aba-favoritos', skipOffstage: false), findsNothing);

    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('aba-favoritos'), findsOneWidget);
    expect(find.text('aba-inicio'), findsNothing);
  });

  testWidgets('a aba guarda o estado ao trocar e voltar', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.byTooltip('MovieAI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('cliques: 0'));
    await tester.pump();

    await tester.tap(find.byTooltip('Início'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('MovieAI'));
    await tester.pumpAndSettle();

    expect(find.text('cliques: 1'), findsOneWidget);
  });

  testWidgets('o voltar do sistema leva ao Início antes de sair', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('aba-inicio'), findsOneWidget);
  });

  testWidgets('em inglês', (tester) async {
    await tester.pumpWidget(buildApp(locale: const Locale('en')));

    for (final label in ['Home', 'MovieAI', 'Favorites']) {
      expect(find.byTooltip(label), findsOneWidget);
    }
  });
}

/// Aba com estado próprio, para ver se ele sobrevive à troca de aba.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => _taps++),
    child: Text('cliques: $_taps'),
  );
}
