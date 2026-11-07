import 'package:app_filmes/data/repositories/ratings_repository.dart';
import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/ui/view/home_page.dart';
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
/// > Como usuário, quero avaliar filmes que já assisti (nota de 1-5 e/ou
/// > reação de humor), para que o algoritmo refine futuras recomendações.
void main() {
  Widget buildApp(
    FakeRatingsRepository ratings, {
    FakeFavoritesRepository? favorites,
    Locale locale = const Locale('pt'),
  }) {
    final movies = FakeMoviesRepository(
      popularMovies: const [dunaMovie, matrixMovie],
      detailsById: const {dunaId: dunaDetails, matrixId: matrixDetails},
    );
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: HomePage(
        viewModel: HomeViewModel(moviesRepository: movies),
        favoritesViewModel: FavoritesViewModel(
          favoritesRepository: favorites ?? FakeFavoritesRepository(),
        )..load(),
        detailsViewModelFactory: (movieId) => MovieDetailsViewModel(
          moviesRepository: movies,
          movieId: movieId,
          watchRegion: 'BR',
        ),
        ratingViewModelFactory: (movieId) =>
            MovieRatingViewModel(ratingsRepository: ratings, movieId: movieId),
        trailerPlayerBuilder: (context, youtubeKey) => const SizedBox(),
      ),
    );
  }

  Future<void> openDetails(WidgetTester tester, int movieId) async {
    await tester.tap(find.byKey(ValueKey(movieId)));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  /// Estrelas marcadas, de 1 a 5.
  List<bool> stars(WidgetTester tester) => [
    for (var n = 1; n <= 5; n++)
      tester
              .widget<IconButton>(
                find.ancestor(
                  of: find.byTooltip(n == 1 ? '1 estrela' : '$n estrelas'),
                  matching: find.byType(IconButton),
                ),
              )
              .isSelected ??
          false,
  ];

  bool moodSelected(WidgetTester tester, String label) => tester
      .widget<ChoiceChip>(
        find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
      )
      .selected;

  testWidgets('filme ainda não avaliado convida a dar nota e humor', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(FakeRatingsRepository()));
    await tester.pumpAndSettle();
    await openDetails(tester, dunaId);

    await tester.ensureVisible(find.text('Sua avaliação'));
    expect(find.text('Sua avaliação'), findsOneWidget);
    // Logo abaixo da sinopse.
    expect(
      tester.getTopLeft(find.text('Sua avaliação')).dy,
      greaterThan(tester.getTopLeft(find.text(dunaDetails.overview!)).dy),
    );
    expect(stars(tester), [false, false, false, false, false]);
    for (final label in [
      'Amei',
      'Divertido',
      'Emocionante',
      'Tenso',
      'Entediante',
    ]) {
      expect(moodSelected(tester, label), isFalse);
    }
  });

  testWidgets(
    'dar nota e humor salva a avaliação, e ela continua lá ao reabrir o filme',
    (tester) async {
      final ratings = FakeRatingsRepository();
      await tester.pumpWidget(buildApp(ratings));
      await tester.pumpAndSettle();
      await openDetails(tester, dunaId);

      await tap(tester, find.byTooltip('4 estrelas'));
      await tap(tester, find.text('Tenso'));

      expect(stars(tester), [true, true, true, true, false]);
      expect(moodSelected(tester, 'Tenso'), isTrue);
      expect(ratings.ratings[dunaId]?.stars, 4);
      expect(ratings.ratings[dunaId]?.mood, Mood.tense);
      expect(ratings.ratings[matrixId], isNull);

      await back(tester);
      await openDetails(tester, dunaId);
      await tester.ensureVisible(find.text('Sua avaliação'));

      expect(stars(tester), [true, true, true, true, false]);
      expect(moodSelected(tester, 'Tenso'), isTrue);
    },
  );

  testWidgets('tocar na nota ou no humor marcado desmarca', (tester) async {
    final ratings = FakeRatingsRepository(
      ratings: {
        dunaId: Rating(
          movieId: dunaId,
          stars: 2,
          mood: Mood.bored,
          ratedAt: DateTime(2026),
        ),
      },
    );
    await tester.pumpWidget(buildApp(ratings));
    await tester.pumpAndSettle();
    await openDetails(tester, dunaId);

    await tap(tester, find.byTooltip('2 estrelas'));
    expect(stars(tester), [false, false, false, false, false]);
    expect(ratings.ratings[dunaId]?.mood, Mood.bored);

    await tap(tester, find.text('Entediante'));
    expect(moodSelected(tester, 'Entediante'), isFalse);
    expect(ratings.ratings, isEmpty);
  });

  testWidgets('dá para avaliar abrindo o filme pelos favoritos', (
    tester,
  ) async {
    final ratings = FakeRatingsRepository();
    await tester.pumpWidget(
      buildApp(
        ratings,
        favorites: FakeFavoritesRepository(movies: [matrixMovie]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favoritos'));
    await tester.pumpAndSettle();
    await openDetails(tester, matrixId);

    await tap(tester, find.byTooltip('1 estrela'));

    expect(ratings.ratings[matrixId]?.stars, 1);
  });

  testWidgets('em inglês', (tester) async {
    await tester.pumpWidget(
      buildApp(FakeRatingsRepository(), locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await openDetails(tester, dunaId);
    await tester.ensureVisible(find.text('Your rating'));

    expect(find.byTooltip('1 star'), findsOneWidget);
    expect(find.byTooltip('5 stars'), findsOneWidget);
    for (final label in ['Loved it', 'Funny', 'Moving', 'Tense', 'Boring']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
