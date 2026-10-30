import 'dart:async';

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

  test('clearFilters limpa a pesquisa e os gêneros e volta aos populares',
      () async {
    final viewModel = HomeViewModel(
      moviesRepository: FakeMoviesRepository(
        popularMovies: const [dunaMovie],
        searchMoviesResult: const [matrixMovie],
      ),
    );
    expect(viewModel.hasFilters, isFalse);

    viewModel.toggleGenre(28);
    await viewModel.search('matrix');
    expect(viewModel.hasFilters, isTrue);

    await viewModel.clearFilters();

    expect(viewModel.hasFilters, isFalse);
    expect(viewModel.searchQuery, isEmpty);
    expect(viewModel.selectedGenreIds, isEmpty);
    expect(viewModel.movies.map((movie) => movie.id), [dunaId]);
  });

  group('pesquisa e gêneros valem um de cada vez', () {
    HomeViewModel build() => HomeViewModel(
          moviesRepository: FakeMoviesRepository(
            popularMovies: const [dunaMovie],
            searchMoviesResult: const [matrixMovie],
            discoverMoviesResult: const [dunaMovie, matrixMovie],
          ),
        );

    test('uma pesquisa nova desmarca os gêneros', () async {
      final viewModel = build();
      viewModel.toggleGenre(28);
      await viewModel.applyGenreFilter();

      await viewModel.search('matrix');

      expect(viewModel.selectedGenreIds, isEmpty);
      expect(viewModel.movies.map((movie) => movie.id), [matrixId]);
    });

    test('aplicar gêneros apaga a pesquisa', () async {
      final viewModel = build();
      await viewModel.search('matrix');

      viewModel.toggleGenre(28);
      await viewModel.applyGenreFilter();

      expect(viewModel.searchQuery, isEmpty);
      expect(viewModel.selectedGenreIds, [28]);
    });

    test('pesquisa vazia volta aos populares e desmarca os gêneros', () async {
      final viewModel = build();
      viewModel.toggleGenre(28);
      await viewModel.applyGenreFilter();

      await viewModel.search('  ');

      expect(viewModel.hasFilters, isFalse);
      expect(viewModel.movies.map((movie) => movie.id), [dunaId]);
    });
  });

  group('com duas buscas ao mesmo tempo', () {
    test('a resposta antiga que chega depois não troca a lista', () async {
      final repository = _SlowMoviesRepository(
        popularMovies: const [dunaMovie],
        searchMoviesResult: const [matrixMovie],
      );
      final viewModel = HomeViewModel(moviesRepository: repository);

      final search = viewModel.search('matrix');
      final refresh = viewModel.load(forceRefresh: true);
      repository.popular.complete();
      await refresh;
      repository.search.complete();
      await search;

      expect(viewModel.movies.map((movie) => movie.id), [dunaId]);
    });

    test('a resposta antiga que chega antes não esconde o carregamento',
        () async {
      final repository = _SlowMoviesRepository(
        popularMovies: const [dunaMovie],
        searchMoviesResult: const [matrixMovie],
      );
      final viewModel = HomeViewModel(moviesRepository: repository);

      final search = viewModel.search('matrix');
      final refresh = viewModel.load(forceRefresh: true);
      repository.search.complete();
      await search;

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.movies, isEmpty);

      repository.popular.complete();
      await refresh;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.movies.map((movie) => movie.id), [dunaId]);
    });
  });
}

/// Repositório falso que só responde quando o teste libera cada chamada, para
/// simular respostas que chegam fora de ordem.
class _SlowMoviesRepository extends FakeMoviesRepository {
  _SlowMoviesRepository({super.popularMovies, super.searchMoviesResult});

  final popular = Completer<void>();
  final search = Completer<void>();

  @override
  Future<Result<List<Movie>>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    await popular.future;
    return super.getPopularMovies(page: page, forceRefresh: forceRefresh);
  }

  @override
  Future<Result<List<Movie>>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    await search.future;
    return super.searchMovies(query: query, page: page);
  }
}
