import 'package:app_filmes/data/api_models/watch_providers.dart';
import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/widgets/watch_providers_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/movie_fixtures.dart';

/// Comportamento coberto por este arquivo:
///
/// > Quero ver em quais plataformas de streaming cada filme está disponível,
/// > para saber onde posso assisti-lo (MOVIEAI-18 / MOVIEAI-14).
void main() {
  /// Monta o widget isolado, com os delegates de tradução e o [locale] pedido.
  Widget buildSection(
    WatchProviderRegion? region, {
    bool compact = false,
    Locale locale = const Locale('pt'),
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(
        body: WatchProvidersSection(region: region, compact: compact),
      ),
    );
  }

  testWidgets('agrupa os serviços por forma de acesso, com link e crédito',
      (tester) async {
    await tester.pumpWidget(buildSection(dunaProvidersBr));

    expect(find.text('Assinatura'), findsOneWidget);
    expect(find.text('Alugar'), findsOneWidget);
    expect(find.text('Comprar'), findsOneWidget);
    expect(find.text('Grátis'), findsNothing, reason: 'grupo vazio é omitido');

    expect(find.byTooltip('Netflix'), findsOneWidget);
    expect(find.byTooltip('Max'), findsOneWidget);
    // Apple TV está em "Alugar" e em "Comprar": um logo em cada grupo.
    expect(find.byTooltip('Apple TV'), findsNWidgets(2));

    expect(find.byKey(WatchProvidersSection.linkKey), findsOneWidget);
    expect(find.text('Fonte: JustWatch'), findsOneWidget);
  });

  testWidgets('tocar no logo de um serviço abre a página do link, que continua',
      (tester) async {
    // No teste não há plugin nativo: o url_launcher cai neste canal.
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final opened = <Map<Object?, Object?>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      if (call.method == 'launch') opened.add(call.arguments as Map);
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(buildSection(dunaProvidersBr));

    await tester.tap(find.byTooltip('Netflix'));
    await tester.pump();

    expect(opened.single['url'], dunaProvidersBr.link);
    expect(opened.single['useWebView'], isFalse, reason: 'abre fora do app');
    expect(find.byKey(WatchProvidersSection.linkKey), findsOneWidget);
    expect(find.text('Fonte: JustWatch'), findsOneWidget);
  });

  testWidgets('ordena os serviços pela prioridade do TMDB', (tester) async {
    await tester.pumpWidget(buildSection(dunaProvidersBr));

    // A fixture traz Netflix (prioridade 5) antes de Max (prioridade 1).
    final maxX = tester.getTopLeft(find.byTooltip('Max')).dx;
    final netflixX = tester.getTopLeft(find.byTooltip('Netflix')).dx;
    expect(maxX, lessThan(netflixX));
  });

  testWidgets('avisa quando o filme não está em nenhum serviço',
      (tester) async {
    await tester.pumpWidget(buildSection(null));

    expect(find.byKey(WatchProvidersSection.unavailableKey), findsOneWidget);
    expect(
      find.text('Indisponível em streaming na sua região'),
      findsOneWidget,
    );
    expect(find.byKey(WatchProvidersSection.linkKey), findsNothing);
  });

  testWidgets('exibe os textos em inglês quando o app está em inglês',
      (tester) async {
    await tester.pumpWidget(
      buildSection(dunaProvidersBr, locale: const Locale('en')),
    );
    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('See where to watch'), findsOneWidget);
    expect(find.text('Source: JustWatch'), findsOneWidget);

    await tester.pumpWidget(buildSection(null, locale: const Locale('en')));
    expect(
      find.text('Not available for streaming in your region'),
      findsOneWidget,
    );
  });

  testWidgets('modo compacto mostra só os logos, cada serviço uma vez',
      (tester) async {
    await tester.pumpWidget(buildSection(dunaProvidersBr, compact: true));

    expect(find.text('Assinatura'), findsNothing);
    expect(find.byKey(WatchProvidersSection.linkKey), findsNothing);
    expect(find.text('Fonte: JustWatch'), findsNothing);
    expect(find.byTooltip('Apple TV'), findsOneWidget);
    expect(find.byTooltip('Netflix'), findsOneWidget);
  });
}
