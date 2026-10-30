import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/movie_genre.dart';
import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/home_page.dart';
import 'package:app_filmes/ui/view/movie_details_page.dart';
import 'package:app_filmes/ui/view/widgets/movie_card.dart';
import 'package:app_filmes/ui/view/widgets/watch_providers_section.dart';
import 'package:app_filmes/ui/view_model/favorites_view_model.dart';
import 'package:app_filmes/ui/view_model/home_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_details_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_rating_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/fake_movies_repository.dart';
import '../../fakes/fake_ratings_repository.dart';
import '../../fakes/movie_fixtures.dart';

/// Comportamento coberto por este arquivo:
///
/// > Dado que estou na tela inicial, quando toco em um cartão de filme, sou
/// > direcionado para uma página com o trailer e as informações do filme.
void main() {
  /// Lista vertical da tela de detalhes. A fileira do elenco também é rolável,
  /// por isso `scrollUntilVisible` precisa saber qual das duas rolar.
  final detailsScrollable = find.byType(Scrollable).first;

  /// Monta o app com o repositório falso e um player de trailer de mentira.
  ///
  /// O player real depende de uma WebView, que não existe no ambiente de
  /// teste; o stub imprime a chave recebida, o que permite verificar que o
  /// trailer certo chegou à tela.
  Widget buildApp(
    FakeMoviesRepository repository, {
    Locale locale = const Locale('pt'),
    List<ChangeNotifier>? createdViewModels,
  }) {
    /// Guarda as view models criadas pelas fábricas em [createdViewModels].
    T track<T extends ChangeNotifier>(T viewModel) {
      createdViewModels?.add(viewModel);
      return viewModel;
    }

    return MaterialApp(
      // A tela de detalhes usa textos traduzidos (seção "Onde assistir").
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: HomePage(
        viewModel: HomeViewModel(moviesRepository: repository),
        favoritesViewModel: FavoritesViewModel(
          favoritesRepository: FakeFavoritesRepository(),
        ),
        detailsViewModelFactory: (movieId) => track(MovieDetailsViewModel(
          moviesRepository: repository,
          movieId: movieId,
          watchRegion: 'BR',
        )),
        ratingViewModelFactory: (movieId) => track(MovieRatingViewModel(
          ratingsRepository: FakeRatingsRepository(),
          movieId: movieId,
        )),
        trailerPlayerBuilder: (context, youtubeKey) =>
            Text('trailer-fake:$youtubeKey'),
      ),
    );
  }

  FakeMoviesRepository buildRepository() => FakeMoviesRepository(
        popularMovies: const [dunaMovie, matrixMovie],
        detailsById: const {dunaId: dunaDetails, matrixId: matrixDetails},
        trailersById: const {dunaId: dunaTrailer},
        watchProvidersById: const {
          dunaId: {'BR': dunaProvidersBr},
        },
      );

  testWidgets('a tela inicial lista os filmes populares em cartões',
      (tester) async {
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Filmes populares'), findsOneWidget);
    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('Duna: Parte Dois'), findsOneWidget);
    expect(find.text('Matrix'), findsOneWidget);
  });

  testWidgets(
    'ao tocar em um cartão, abre a página com o trailer e as informações do filme',
    (tester) async {
      final repository = buildRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MovieCard).first);
      await tester.pumpAndSettle();

      // Saímos da tela inicial e chegamos à tela de detalhes.
      expect(find.byType(MovieDetailsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Os detalhes pedidos são os do filme tocado.
      expect(repository.requestedDetailIds, [dunaId]);
      expect(repository.requestedTrailerIds, [dunaId]);

      // O trailer é exibido, com a chave do vídeo do filme selecionado.
      expect(find.byKey(MovieDetailsPage.trailerKey), findsOneWidget);
      expect(find.text('trailer-fake:${dunaTrailer.key}'), findsOneWidget);

      // As informações do filme acompanham o trailer.
      expect(find.text('Duna: Parte Dois'), findsWidgets); // AppBar e título
      expect(find.text('Longa vida aos lutadores.'), findsOneWidget);
      expect(find.text(dunaDetails.overview!), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2h 46min'), findsOneWidget);
      expect(find.text('8,2'), findsOneWidget);
      expect(find.text('Ficção científica'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);
      expect(find.text('Direção: Denis Villeneuve'), findsOneWidget);
      // Classificação da região do usuário (BR), não a dos EUA.
      expect(find.text('14'), findsOneWidget);
      expect(find.text('PG-13'), findsNothing);
      expect(find.byTooltip('Classificação indicativa: 14'), findsOneWidget);

      // Elenco principal, na ordem dos créditos.
      await tester.scrollUntilVisible(
        find.text('Elenco'),
        200,
        scrollable: detailsScrollable,
      );
      expect(
        tester.getTopLeft(find.text('Timothée Chalamet')).dx,
        lessThan(tester.getTopLeft(find.text('Zendaya')).dx),
      );
      expect(find.text('Paul Atreides'), findsOneWidget);

      // E onde assisti-lo, na região informada à view model.
      expect(repository.requestedWatchRegions, ['BR']);
      await tester.scrollUntilVisible(
        find.text('Onde assistir'),
        200,
        scrollable: detailsScrollable,
      );
      expect(find.byTooltip('Netflix'), findsOneWidget);
    },
  );

  testWidgets('cada cartão abre a página do seu próprio filme', (tester) async {
    final repository = buildRepository();
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey(matrixId)));
    await tester.pumpAndSettle();

    expect(repository.requestedDetailIds, [matrixId]);
    expect(find.text('Matrix'), findsWidgets);
    expect(find.text('2h 16min'), findsOneWidget);
    // Sem créditos nem classificação: as seções somem.
    expect(find.text('Elenco'), findsNothing);
    expect(find.textContaining('Direção'), findsNothing);
  });

  testWidgets('o elenco não estoura com a fonte do sistema no dobro',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Paul Atreides'),
      200,
      scrollable: detailsScrollable,
    );

    // Um overflow de layout aparece aqui como exceção.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'filme sem trailer mostra o aviso e mantém as informações',
    (tester) async {
      final repository = buildRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey(matrixId)));
      await tester.pumpAndSettle();

      expect(find.byKey(MovieDetailsPage.trailerKey), findsNothing);
      expect(find.byKey(MovieDetailsPage.emptyTrailerKey), findsOneWidget);
      expect(find.text('Trailer não disponível'), findsOneWidget);
      expect(find.text(matrixDetails.overview!), findsOneWidget);

      // Matrix não tem serviços cadastrados no fake: a tela avisa.
      await tester.scrollUntilVisible(
        find.byKey(WatchProvidersSection.unavailableKey),
        200,
      );
      expect(
        find.text('Indisponível em streaming na sua região'),
        findsOneWidget,
      );
    },
  );

  testWidgets('a tela de detalhes mantém o filme quando o app é reconstruído',
      (tester) async {
    final repository = buildRepository();
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();

    // Um novo MaterialApp reconstrói o Navigator, que reconstrói a página da
    // rota (como numa troca de idioma ou num hot reload).
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text(dunaDetails.overview!), findsOneWidget);
    expect(repository.requestedDetailIds, [dunaId]);
  });

  testWidgets('voltar dos detalhes descarta as view models da tela',
      (tester) async {
    final created = <ChangeNotifier>[];
    await tester.pumpWidget(
      buildApp(buildRepository(), createdViewModels: created),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(created, hasLength(2), reason: 'detalhes e avaliação');
    for (final viewModel in created) {
      expect(
        () => ChangeNotifier.debugAssertNotDisposed(viewModel),
        throwsFlutterError,
      );
    }
  });

  testWidgets('é possível voltar da tela de detalhes para a tela inicial',
      (tester) async {
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailsPage), findsOneWidget);

    // `pageBack()` procura o botão pelo tooltip em inglês ("Back"); com o app
    // em português o tooltip é "Voltar", então tocamos no widget diretamente.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailsPage), findsNothing);
    expect(find.byType(MovieCard), findsNWidgets(2));
  });

  testWidgets('limpar a pesquisa apaga o campo e volta aos populares',
      (tester) async {
    final repository = FakeMoviesRepository(
      popularMovies: const [dunaMovie, matrixMovie],
      searchMoviesResult: const [matrixMovie],
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Limpar filtros'), findsNothing);

    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byType(MovieCard), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('matrix'), findsNothing);
    expect(find.byTooltip('Limpar filtros'), findsNothing);
  });

  testWidgets('aplicar gêneros apaga o texto da pesquisa', (tester) async {
    final repository = FakeMoviesRepository(
      popularMovies: const [dunaMovie, matrixMovie],
      searchMoviesResult: const [matrixMovie],
      discoverMoviesResult: const [dunaMovie],
      movieGenres: const [MovieGenre(id: 878, name: 'Ficção científica')],
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'matrix');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filtro avançado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('matrix'), findsNothing);
    expect(find.byKey(const ValueKey(dunaId)), findsOneWidget);
  });

  testWidgets('a tela inicial informa quando não há filmes para exibir',
      (tester) async {
    await tester.pumpWidget(buildApp(FakeMoviesRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum filme encontrado no momento.'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('a tela inicial mostra o erro e permite tentar novamente',
      (tester) async {
    final repository = FakeMoviesRepository(
      popularError: Exception('falha de rede'),
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar os filmes.'), findsOneWidget);
    // O detalhe técnico vai para o log, não para o usuário.
    expect(find.textContaining('falha de rede'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repository.forcedRefreshCount, 1);
  });

  testWidgets('o cartão exibe o filme recebido, sem conhecer o repositório',
      (tester) async {
    Movie? tapped;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: MovieCard(
            movie: dunaMovie,
            onTap: () => tapped = dunaMovie,
          ),
        ),
      ),
    );

    expect(find.text('Duna: Parte Dois'), findsOneWidget);
    expect(find.text('8,2'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);

    await tester.tap(find.byType(MovieCard));
    expect(tapped, same(dunaMovie));
  });

  testWidgets('com mais de 10 no elenco, "Ver todos" abre o elenco completo',
      (tester) async {
    final repository = FakeMoviesRepository(
      popularMovies: const [matrixMovie],
      detailsById: {
        matrixId: MovieDetails(
          id: matrixId,
          title: 'Matrix',
          credits: Credits(cast: [
            for (var i = 1; i <= 11; i++) CastMember(name: 'Ator $i', order: i),
          ]),
        ),
      },
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard));
    await tester.pumpAndSettle();

    // O botão já existe fora da tela (dentro do cacheExtent da lista), então
    // basta rolar até ele.
    await tester.ensureVisible(find.text('Ver todos'));
    await tester.pumpAndSettle();
    expect(find.text('Ator 11'), findsNothing);

    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.text('Elenco'), findsOneWidget, reason: 'título da página');
    await tester.scrollUntilVisible(find.text('Ator 11'), 200);
    expect(find.text('Ator 11'), findsOneWidget);
  });

  testWidgets('falha em onde assistir não aparece como "indisponível"',
      (tester) async {
    final repository = FakeMoviesRepository(
      popularMovies: const [dunaMovie],
      detailsById: const {dunaId: dunaDetails},
      watchProvidersError: Exception('falha de rede'),
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Não foi possível carregar onde assistir'),
      200,
      scrollable: detailsScrollable,
    );
    expect(find.byKey(WatchProvidersSection.unavailableKey), findsNothing);
  });

  testWidgets('tocar no logo de um serviço abre o link do TMDB fora do app',
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
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();

    // O logo já existe fora da tela (dentro do cacheExtent da lista).
    await tester.ensureVisible(find.byTooltip('Netflix'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Netflix'));
    await tester.pump();

    expect(opened.single['url'], dunaProvidersBr.link);
    expect(opened.single['useWebView'], isFalse, reason: 'abre fora do app');
  });

  group('com a barra de navegação do sistema por cima do app', () {
    /// Altura da barra de navegação do Android (edge-to-edge) na tela de teste.
    const navigationBar = 48.0;

    /// Tela de 800x600 com a barra no rodapé. É a área que o conteúdo, ao fim
    /// da rolagem, não pode invadir.
    void useNavigationBar(WidgetTester tester) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      tester.view.padding = const FakeViewPadding(bottom: navigationBar);
      tester.view.viewPadding = const FakeViewPadding(bottom: navigationBar);
      addTearDown(tester.view.reset);
    }

    testWidgets('o último filme da lista termina acima da barra',
        (tester) async {
      useNavigationBar(tester);
      final movies = [
        for (var id = 1; id <= 12; id++) Movie(id: id, title: 'Filme $id'),
      ];
      await tester.pumpWidget(buildApp(FakeMoviesRepository(popularMovies: movies)));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(const ValueKey(12))).dy,
        lessThanOrEqualTo(600 - navigationBar),
      );
    });

    testWidgets('o fim da tela de detalhes termina acima da barra',
        (tester) async {
      useNavigationBar(tester);
      await tester.pumpWidget(buildApp(buildRepository()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MovieCard).first);
      await tester.pumpAndSettle();

      await tester.drag(detailsScrollable, const Offset(0, -10000));
      await tester.pumpAndSettle();

      // "Fonte: JustWatch" é a última linha da tela.
      expect(
        tester.getBottomLeft(find.text('Fonte: JustWatch')).dy,
        lessThanOrEqualTo(600 - navigationBar),
      );
    });
  });

  group('em inglês', () {
    testWidgets('a home e os detalhes aparecem traduzidos e formatados',
        (tester) async {
      await tester.pumpWidget(
        buildApp(buildRepository(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Popular movies'), findsOneWidget);
      expect(find.text('Movie title'), findsOneWidget);

      await tester.tap(find.byType(MovieCard).first);
      await tester.pumpAndSettle();

      expect(find.text('Synopsis'), findsOneWidget);
      expect(find.text('8.2'), findsOneWidget);
      expect(find.text('2h 46m'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Where to watch'),
        200,
        scrollable: detailsScrollable,
      );
      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('filme sem trailer mostra o aviso traduzido', (tester) async {
      await tester.pumpWidget(
        buildApp(buildRepository(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey(matrixId)));
      await tester.pumpAndSettle();

      expect(find.text('Trailer not available'), findsOneWidget);
    });

    testWidgets('o erro aparece traduzido, com o botão de tentar de novo',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          FakeMoviesRepository(popularError: Exception('falha de rede')),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load the movies."), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
