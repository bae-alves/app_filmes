import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/ui/view_model/favorites_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  test('load traz a lista salva', () async {
    final viewModel = FavoritesViewModel(
      favoritesRepository: FakeFavoritesRepository(movies: [dunaMovie]),
    );

    await viewModel.load();

    expect(viewModel.favorites.map((m) => m.id), [dunaId]);
    expect(viewModel.isFavorite(dunaId), isTrue);
    expect(viewModel.isFavorite(matrixId), isFalse);
    expect(viewModel.error, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('falha ao ler a lista fica em error', () async {
    final viewModel = FavoritesViewModel(
      favoritesRepository: FakeFavoritesRepository(
        readError: Exception('banco indisponível'),
      ),
    );

    await viewModel.load();

    expect(viewModel.error, isNotNull);
    expect(viewModel.favorites, isEmpty);
  });

  test('toggle adiciona no topo e, de novo, remove — e grava', () async {
    final repository = FakeFavoritesRepository(movies: [matrixMovie]);
    final viewModel = FavoritesViewModel(favoritesRepository: repository);
    await viewModel.load();

    await viewModel.toggle(dunaMovie);
    expect(viewModel.favorites.map((m) => m.id), [dunaId, matrixId]);
    expect(repository.movieIds, [dunaId, matrixId]);

    await viewModel.toggle(dunaMovie);
    expect(viewModel.isFavorite(dunaId), isFalse);
    expect(repository.movieIds, [matrixId]);
  });

  test('o coração muda na hora e volta se a gravação falhar', () async {
    final repository = FakeFavoritesRepository(
      writeError: Exception('disco cheio'),
    );
    final viewModel = FavoritesViewModel(favoritesRepository: repository);
    final seen = <bool>[];
    viewModel.addListener(() => seen.add(viewModel.isFavorite(dunaId)));

    await viewModel.toggle(dunaMovie);

    expect(seen, [true, false]);
    expect(viewModel.isFavorite(dunaId), isFalse);
  });

  group('remove e undoRemove', () {
    late FakeFavoritesRepository repository;
    late FavoritesViewModel viewModel;

    setUp(() async {
      repository = FakeFavoritesRepository(
        movies: [matrixMovie, dunaMovie, otherMovie],
      );
      viewModel = FavoritesViewModel(favoritesRepository: repository);
      await viewModel.load();
    });

    test('remove tira o filme da lista e do repositório', () async {
      await viewModel.remove(dunaId);

      expect(viewModel.favorites.map((m) => m.id), [matrixId, otherId]);
      expect(repository.movieIds, [matrixId, otherId]);
    });

    test('desfazer devolve o filme ao mesmo lugar, também no repositório',
        () async {
      await viewModel.remove(dunaId);
      await viewModel.undoRemove();

      expect(viewModel.favorites.map((m) => m.id), [matrixId, dunaId, otherId]);
      expect(repository.movieIds, [matrixId, dunaId, otherId]);
    });

    test('desfazer só vale uma vez', () async {
      await viewModel.remove(dunaId);
      await viewModel.undoRemove();
      await viewModel.remove(dunaId);
      await viewModel.undoRemove();
      await viewModel.undoRemove();

      expect(repository.movieIds, [matrixId, dunaId, otherId]);
    });

    test('falha ao remover devolve o filme à lista', () async {
      repository.writeError = Exception('disco cheio');

      await viewModel.remove(dunaId);

      expect(viewModel.favorites.map((m) => m.id), [matrixId, dunaId, otherId]);
    });
  });
}

const otherId = 1;
const otherMovie = Movie(id: otherId, title: 'Outro filme');
