import 'package:app_filmes/data/repositories/ratings_repository.dart';
import 'package:app_filmes/ui/view_model/movie_rating_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_ratings_repository.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  MovieRatingViewModel build(FakeRatingsRepository repository) =>
      MovieRatingViewModel(ratingsRepository: repository, movieId: dunaId);

  test('load traz a avaliação salva do filme', () async {
    final viewModel = build(
      FakeRatingsRepository(
        ratings: {
          dunaId: Rating(
            movieId: dunaId,
            stars: 4,
            mood: Mood.moved,
            ratedAt: DateTime(2026),
          ),
          matrixId: Rating(
            movieId: matrixId,
            stars: 1,
            ratedAt: DateTime(2026),
          ),
        },
      ),
    );

    await viewModel.load();

    expect(viewModel.stars, 4);
    expect(viewModel.mood, Mood.moved);
  });

  test('filme sem avaliação começa sem nota e sem humor', () async {
    final viewModel = build(FakeRatingsRepository());

    await viewModel.load();

    expect(viewModel.stars, isNull);
    expect(viewModel.mood, isNull);
  });

  test(
    'setStars e setMood gravam a avaliação, um sem apagar o outro',
    () async {
      final repository = FakeRatingsRepository();
      final viewModel = build(repository);
      await viewModel.load();

      await viewModel.setStars(3);
      expect(repository.ratings[dunaId]?.stars, 3);
      expect(repository.ratings[dunaId]?.mood, isNull);

      await viewModel.setMood(Mood.funny);
      expect(viewModel.stars, 3);
      expect(viewModel.mood, Mood.funny);
      expect(repository.ratings[dunaId]?.stars, 3);
      expect(repository.ratings[dunaId]?.mood, Mood.funny);

      await viewModel.setStars(5);
      expect(repository.ratings[dunaId]?.stars, 5);
      expect(repository.ratings[dunaId]?.mood, Mood.funny);
    },
  );

  test('escolher de novo a mesma nota ou o mesmo humor desmarca', () async {
    final repository = FakeRatingsRepository();
    final viewModel = build(repository);
    await viewModel.load();
    await viewModel.setStars(2);
    await viewModel.setMood(Mood.bored);

    await viewModel.setStars(2);
    expect(viewModel.stars, isNull);
    expect(repository.ratings[dunaId]?.mood, Mood.bored);

    await viewModel.setMood(Mood.bored);
    expect(viewModel.mood, isNull);
    // Sem nota e sem humor, não sobra avaliação.
    expect(repository.ratings, isEmpty);
  });

  test('falha ao gravar volta ao que era', () async {
    final repository = FakeRatingsRepository();
    final viewModel = build(repository);
    await viewModel.load();
    await viewModel.setStars(4);

    repository.writeError = Exception('disco cheio');
    var notified = 0;
    viewModel.addListener(() => notified++);
    await viewModel.setStars(1);

    expect(viewModel.stars, 4);
    expect(repository.ratings[dunaId]?.stars, 4);
    // Mostra a mudança na hora e depois a desfaz.
    expect(notified, 2);
  });

  test('load e setStars que terminam depois do dispose não falham', () async {
    final loading = build(FakeRatingsRepository());
    final load = loading.load();
    loading.dispose();
    await expectLater(load, completes);

    final saving = build(FakeRatingsRepository());
    await saving.load();
    final save = saving.setStars(3);
    saving.dispose();
    await expectLater(save, completes);
  });
}
