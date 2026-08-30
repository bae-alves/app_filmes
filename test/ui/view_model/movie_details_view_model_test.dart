import 'package:app_filmes/ui/view_model/movie_details_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_movies_repository.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  test('load busca detalhes e trailer do filme informado', () async {
    final repository = FakeMoviesRepository(
      detailsById: const {dunaId: dunaDetails},
      trailersById: const {dunaId: dunaTrailer},
    );
    final viewModel = MovieDetailsViewModel(
      moviesRepository: repository,
      movieId: dunaId,
    );

    await viewModel.load();

    expect(repository.requestedDetailIds, [dunaId]);
    expect(repository.requestedTrailerIds, [dunaId]);
    expect(viewModel.details?.title, 'Duna: Parte Dois');
    expect(viewModel.trailerYoutubeKey, dunaTrailer.key);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNull);
  });

  test('trailerYoutubeKey é null quando o filme não tem trailer', () async {
    final viewModel = MovieDetailsViewModel(
      moviesRepository: FakeMoviesRepository(
        detailsById: const {matrixId: matrixDetails},
      ),
      movieId: matrixId,
    );

    await viewModel.load();

    expect(viewModel.details?.title, 'Matrix');
    expect(viewModel.trailer, isNull);
    expect(viewModel.trailerYoutubeKey, isNull);
  });

  test('falha no trailer não impede a exibição das informações', () async {
    final viewModel = MovieDetailsViewModel(
      moviesRepository: FakeMoviesRepository(
        detailsById: const {dunaId: dunaDetails},
        trailerError: Exception('vídeos indisponíveis'),
      ),
      movieId: dunaId,
    );

    await viewModel.load();

    expect(viewModel.details?.title, 'Duna: Parte Dois');
    expect(viewModel.trailer, isNull);
    expect(viewModel.error, isNull, reason: 'a tela ainda é utilizável');
  });

  test('falha nos detalhes vira erro exposto para a view', () async {
    final failure = Exception('404');
    final viewModel = MovieDetailsViewModel(
      moviesRepository: FakeMoviesRepository(detailsError: failure),
      movieId: dunaId,
    );

    await viewModel.load();

    expect(viewModel.details, isNull);
    expect(viewModel.error, same(failure));
  });

  test('notifica a view no início e no fim do carregamento', () async {
    final viewModel = MovieDetailsViewModel(
      moviesRepository: FakeMoviesRepository(
        detailsById: const {dunaId: dunaDetails},
      ),
      movieId: dunaId,
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load();

    expect(notifications, 2);
  });
}
