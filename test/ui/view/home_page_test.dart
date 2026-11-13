import 'package:app_filmes/data/api_models/movie_genre.dart';
import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/app_shell.dart';
import 'package:app_filmes/ui/view/home_page.dart';
import 'package:app_filmes/ui/view/widgets/poster_card.dart';
import 'package:app_filmes/ui/view_model/favorites_view_model.dart';
import 'package:app_filmes/ui/view_model/home_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_details_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_rating_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/fake_movies_repository.dart';
import '../../fakes/fake_ratings_repository.dart';
import '../../fakes/movie_fixtures.dart';

/// Comportamento coberto por este arquivo:
///
/// > Na tela inicial, vejo o filme mais popular em destaque, filtro por gênero
/// > com um toque, salvo filmes direto da grade e chego ao MovieAI.
void main() {
  const sciFi = MovieGenre(id: 878, name: 'Ficção científica');

  Widget buildApp(
    FakeMoviesRepository movies, {
    FakeFavoritesRepository? favorites,
  }) {
    final home = HomePage(
      viewModel: HomeViewModel(moviesRepository: movies),
      favoritesViewModel: FavoritesViewModel(
        favoritesRepository: favorites ?? FakeFavoritesRepository(),
      )..load(),
      detailsViewModelFactory: (movieId) => MovieDetailsViewModel(
        moviesRepository: movies,
        movieId: movieId,
        watchRegion: 'BR',
      ),
      ratingViewModelFactory: (movieId) => MovieRatingViewModel(
        ratingsRepository: FakeRatingsRepository(),
        movieId: movieId,
      ),
      trailerPlayerBuilder: (context, youtubeKey) => const SizedBox(),
    );
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: AppShell(
        home: home,
        assistant: const Text('aba-movieai'),
        favorites: const SizedBox(),
      ),
    );
  }

  /// Na tela de teste (800 × 600), o destaque ocupa quase toda a área
  /// visível. Rola até [finder] (para baixo se ele ainda não foi montado) e
  /// toca. Passe finders com `skipOffstage: false`, para achar também o que
  /// já rolou para cima.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  FakeMoviesRepository repository() => FakeMoviesRepository(
    popularMovies: const [dunaMovie, matrixMovie],
    discoverMoviesResult: const [matrixMovie],
    movieGenres: const [sciFi],
  );

  testWidgets('o primeiro popular vai para o destaque e o resto para a grade', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(repository()));
    await tester.pumpAndSettle();

    expect(find.text('#1 em alta'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey(dunaId)),
        matching: find.text('Duna: Parte Dois'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byType(PosterCard),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(PosterCard), findsOneWidget);
    expect(find.widgetWithText(PosterCard, 'Matrix'), findsOneWidget);
  });

  testWidgets('tocar num gênero filtra na hora, e "Todos" volta', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(repository()));
    await tester.pumpAndSettle();
    // Partes que podem ter rolado para fora da tela, mas continuam montadas.
    Finder built(String text) => find.text(text, skipOffstage: false);

    await tapVisible(
      tester,
      find.widgetWithText(ChoiceChip, 'Ficção científica', skipOffstage: false),
    );

    expect(built('#1 em alta'), findsNothing, reason: 'sem destaque');
    expect(built('Resultados'), findsOneWidget);
    expect(find.byKey(const ValueKey(matrixId)), findsOneWidget);
    expect(find.byKey(const ValueKey(dunaId)), findsNothing);

    await tapVisible(
      tester,
      find.widgetWithText(ChoiceChip, 'Todos', skipOffstage: false),
    );

    expect(built('#1 em alta'), findsOneWidget);
    expect(built('Filmes populares'), findsOneWidget);
  });

  testWidgets('o coração do pôster salva o filme nos favoritos', (
    tester,
  ) async {
    final favorites = FakeFavoritesRepository();
    await tester.pumpWidget(buildApp(repository(), favorites: favorites));
    await tester.pumpAndSettle();

    final heart = find.descendant(
      of: find.byKey(const ValueKey(matrixId), skipOffstage: false),
      matching: find.byTooltip('Adicionar aos favoritos', skipOffstage: false),
    );
    await tapVisible(tester, heart);

    expect(favorites.movieIds, [matrixId]);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey(matrixId)),
        matching: find.byTooltip('Remover dos favoritos'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('o cartão do MovieAI abre a aba do assistente', (tester) async {
    await tester.pumpWidget(buildApp(repository()));
    await tester.pumpAndSettle();

    await tapVisible(
      tester,
      find.text('Perguntar ao MovieAI', skipOffstage: false),
    );

    expect(find.text('aba-movieai'), findsOneWidget);
  });
}
