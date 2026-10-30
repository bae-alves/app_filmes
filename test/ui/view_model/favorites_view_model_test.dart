import 'package:app_filmes/ui/view_model/favorites_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  test('load traz a lista salva', () async {
    final viewModel = FavoritesViewModel(
      favoritesRepository: FakeFavoritesRepository(favorites: [dunaMovie]),
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
    final repository = FakeFavoritesRepository(favorites: [matrixMovie]);
    final viewModel = FavoritesViewModel(favoritesRepository: repository);
    await viewModel.load();

    await viewModel.toggle(dunaMovie);
    expect(viewModel.favorites.map((m) => m.id), [dunaId, matrixId]);
    expect(repository.favorites.map((m) => m.id), [dunaId, matrixId]);

    await viewModel.toggle(dunaMovie);
    expect(viewModel.isFavorite(dunaId), isFalse);
    expect(repository.favorites.map((m) => m.id), [matrixId]);
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
}
