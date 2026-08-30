import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/ui/view_model/home_view_model.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_movies_repository.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  test('começa vazia, sem carregar e sem erro', () {
    final viewModel = HomeViewModel(
      moviesRepository: FakeMoviesRepository(),
    );

    expect(viewModel.movies, isEmpty);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNull);
  });

  test('load publica os filmes e notifica a view', () async {
    final viewModel = HomeViewModel(
      moviesRepository: FakeMoviesRepository(
        popularMovies: const [dunaMovie, matrixMovie],
      ),
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    final result = await viewModel.load();

    expect(result, isA<Ok<List<Movie>>>());
    expect(viewModel.movies.map((movie) => movie.id), [dunaId, matrixId]);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.error, isNull);
    // Uma notificação ao entrar em carregamento e outra ao terminar.
    expect(notifications, 2);
  });

  test('load guarda o erro e limpa a lista quando o repositório falha', () async {
    final failure = Exception('sem internet');
    final viewModel = HomeViewModel(
      moviesRepository: FakeMoviesRepository(
        popularMovies: const [dunaMovie],
        popularError: failure,
      ),
    );

    final result = await viewModel.load();

    expect(result, isA<Error<List<Movie>>>());
    expect(viewModel.movies, isEmpty);
    expect(viewModel.error, same(failure));
  });

  test('isEmpty só é verdadeiro após um carregamento bem-sucedido e vazio',
      () async {
    final viewModel = HomeViewModel(moviesRepository: FakeMoviesRepository());

    expect(viewModel.isEmpty, isTrue, reason: 'nada carregado ainda');

    await viewModel.load();

    expect(viewModel.isEmpty, isTrue);
    expect(viewModel.error, isNull);
  });

  test('load repassa forceRefresh para o repositório', () async {
    final repository = FakeMoviesRepository(popularMovies: const [dunaMovie]);
    final viewModel = HomeViewModel(moviesRepository: repository);

    await viewModel.load();
    await viewModel.load(forceRefresh: true);

    expect(repository.forcedRefreshCount, 1);
  });
}
