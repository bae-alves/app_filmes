import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/favorites_page.dart';
import 'package:app_filmes/ui/view/home_page.dart';
import 'package:app_filmes/ui/view/movie_details_page.dart';
import 'package:app_filmes/ui/view/widgets/movie_card.dart';
import 'package:app_filmes/ui/view_model/favorites_view_model.dart';
import 'package:app_filmes/ui/view_model/home_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/fake_movies_repository.dart';
import '../../fakes/movie_fixtures.dart';

/// Comportamento coberto por este arquivo:
///
/// > Como usuário, quero salvar filmes em uma lista de favoritos/watchlist,
/// > para organizar o que quero assistir depois.
void main() {
  Widget buildApp(
    FakeFavoritesRepository favorites, {
    Locale locale = const Locale('pt'),
  }) {
    final movies = FakeMoviesRepository(
      popularMovies: const [dunaMovie, matrixMovie],
      detailsById: const {dunaId: dunaDetails, matrixId: matrixDetails},
    );
    final favoritesViewModel = FavoritesViewModel(
      favoritesRepository: favorites,
    )..load();
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: HomePage(
        viewModel: HomeViewModel(moviesRepository: movies),
        favoritesViewModel: favoritesViewModel,
        detailsViewModelFactory: (movieId) => MovieDetailsViewModel(
          moviesRepository: movies,
          movieId: movieId,
          watchRegion: 'BR',
        ),
        trailerPlayerBuilder: (context, youtubeKey) => const SizedBox(),
      ),
    );
  }

  Future<void> openFavorites(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritesPage), findsOneWidget);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  testWidgets('a lista começa vazia e explica como adicionar', (tester) async {
    await tester.pumpWidget(buildApp(FakeFavoritesRepository()));
    await tester.pumpAndSettle();

    await openFavorites(tester);

    expect(find.textContaining('Nenhum filme nos favoritos'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets(
    'favoritar na tela de detalhes salva o filme e ele aparece na lista',
    (tester) async {
      final favorites = FakeFavoritesRepository();
      await tester.pumpWidget(buildApp(favorites));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey(dunaId)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Adicionar aos favoritos'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
      expect(favorites.movieIds, [dunaId]);

      await back(tester);
      await openFavorites(tester);

      expect(find.byType(MovieCard), findsOneWidget);
      expect(find.text('Duna: Parte Dois'), findsOneWidget);
    },
  );

  testWidgets(
    'tocar num favorito abre os detalhes, e desfavoritar o tira da lista',
    (tester) async {
      final favorites = FakeFavoritesRepository(
        movies: [matrixMovie, dunaMovie],
      );
      await tester.pumpWidget(buildApp(favorites));
      await tester.pumpAndSettle();
      await openFavorites(tester);

      // Mais recente primeiro.
      expect(
        tester.getTopLeft(find.text('Matrix')).dy,
        lessThan(tester.getTopLeft(find.text('Duna: Parte Dois')).dy),
      );

      await tester.tap(find.byKey(const ValueKey(matrixId)));
      await tester.pumpAndSettle();
      expect(find.byType(MovieDetailsPage), findsOneWidget);

      await tester.tap(find.byTooltip('Remover dos favoritos'));
      await tester.pumpAndSettle();
      await back(tester);

      expect(find.byType(FavoritesPage), findsOneWidget);
      expect(find.byKey(const ValueKey(matrixId)), findsNothing);
      expect(find.byKey(const ValueKey(dunaId)), findsOneWidget);
      expect(favorites.movieIds, [dunaId]);
    },
  );

  group('remover da lista', () {
    /// Cartões na tela, de cima para baixo. O SnackBar também usa um
    /// Dismissible, com outra chave; por isso o filtro pelo tipo da chave.
    List<int> cardIds(WidgetTester tester) => [
          for (final d in tester.widgetList<Dismissible>(
            find.byType(Dismissible),
          ))
            if (d.key case ValueKey<int>(:final value)) value,
        ];

    Future<FakeFavoritesRepository> openList(WidgetTester tester) async {
      final favorites = FakeFavoritesRepository(
        movies: [matrixMovie, dunaMovie],
      );
      await tester.pumpWidget(buildApp(favorites));
      await tester.pumpAndSettle();
      await openFavorites(tester);
      return favorites;
    }

    testWidgets('o botão de lixeira remove e oferece desfazer', (tester) async {
      final favorites = await openList(tester);

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey(matrixId)),
          matching: find.byTooltip('Remover dos favoritos'),
        ),
      );
      await tester.pumpAndSettle();

      expect(cardIds(tester), [dunaId]);
      expect(favorites.movieIds, [dunaId]);
      expect(find.text('Matrix saiu dos favoritos'), findsOneWidget);

      await tester.tap(find.text('Desfazer'));
      await tester.pumpAndSettle();

      // De volta ao mesmo lugar: no topo, como antes.
      expect(cardIds(tester), [matrixId, dunaId]);
      expect(favorites.movieIds, [matrixId, dunaId]);
    });

    testWidgets('arrastar o cartão para a esquerda remove o filme',
        (tester) async {
      final favorites = await openList(tester);

      await tester.drag(
        find.byKey(const ValueKey(dunaId)),
        const Offset(-800, 0),
      );
      await tester.pumpAndSettle();

      expect(cardIds(tester), [matrixId]);
      expect(favorites.movieIds, [matrixId]);
      expect(find.text('Duna: Parte Dois saiu dos favoritos'), findsOneWidget);
    });

    testWidgets('o aviso some sozinho e o filme continua removido',
        (tester) async {
      final favorites = await openList(tester);

      await tester.tap(find.byTooltip('Remover dos favoritos').first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 9));
      expect(find.text('Desfazer'), findsOneWidget, reason: 'ainda dá tempo');

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Desfazer'), findsNothing);
      expect(favorites.movieIds, [dunaId]);
    });

    testWidgets('remover o último mostra a lista vazia', (tester) async {
      await openList(tester);

      await tester.tap(find.byTooltip('Remover dos favoritos').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remover dos favoritos').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Nenhum filme nos favoritos'), findsOneWidget);
    });
  });

  testWidgets('falha ao ler a lista mostra o erro e permite tentar de novo',
      (tester) async {
    final favorites = FakeFavoritesRepository(
      readError: Exception('banco indisponível'),
    );
    await tester.pumpWidget(buildApp(favorites));
    await tester.pumpAndSettle();
    await openFavorites(tester);

    expect(find.text('Não foi possível carregar os favoritos.'), findsOneWidget);

    favorites.readError = null;
    await favorites.addFavorite(dunaMovie);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsOneWidget);
  });

  testWidgets('em inglês, a lista e o coração aparecem traduzidos',
      (tester) async {
    await tester.pumpWidget(
      buildApp(FakeFavoritesRepository(), locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey(dunaId)));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add to favorites'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pumpAndSettle();
    await back(tester);
    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove from favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Removed Duna: Parte Dois from favorites'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.textContaining('No favorites yet'), findsOneWidget);
  });
}
