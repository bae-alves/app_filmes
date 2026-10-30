import 'package:app_filmes/data/repositories/favorites_repository.dart';
import 'package:app_filmes/data/repositories/favorites_repository_local.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../fakes/movie_fixtures.dart';

void main() {
  late Database database;
  late FavoritesRepositoryLocal repository;
  late int clock;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    // Banco novo, em memória, a cada teste: o mesmo esquema do app.
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    clock = 0;
    repository = FavoritesRepositoryLocal(
      database: database,
      now: () => DateTime.fromMillisecondsSinceEpoch(++clock),
    );
  });

  tearDown(() => database.close());

  Future<List<Favorite>> favorites() async =>
      switch (await repository.getFavorites()) {
        Ok(:final value) => value,
        Error(:final error) => throw error,
      };

  test('começa vazio', () async {
    expect(await favorites(), isEmpty);
  });

  test('guarda o resumo do filme e devolve o mais recente primeiro', () async {
    await repository.addFavorite(dunaMovie);
    await repository.addFavorite(matrixMovie);

    final saved = await favorites();
    expect(saved.map((f) => f.movie.id), [matrixId, dunaId]);
    expect(saved.last.addedAt, DateTime.fromMillisecondsSinceEpoch(1));

    final duna = saved.last.movie;
    expect(duna.title, dunaMovie.title);
    expect(duna.originalTitle, dunaMovie.originalTitle);
    expect(duna.overview, dunaMovie.overview);
    expect(duna.posterPath, dunaMovie.posterPath);
    expect(duna.backdropPath, dunaMovie.backdropPath);
    expect(duna.releaseDate, dunaMovie.releaseDate);
    expect(duna.voteAverage, dunaMovie.voteAverage);
    expect(duna.voteCount, dunaMovie.voteCount);
  });

  test('favoritar de novo não duplica e leva o filme para o topo', () async {
    await repository.addFavorite(dunaMovie);
    await repository.addFavorite(matrixMovie);
    await repository.addFavorite(dunaMovie);

    expect((await favorites()).map((f) => f.movie.id), [dunaId, matrixId]);
  });

  test('addedAt informado devolve o filme à posição original', () async {
    await repository.addFavorite(dunaMovie); // added_at 1
    await repository.addFavorite(matrixMovie); // added_at 2
    final dunaAddedAt = (await favorites()).last.addedAt;

    await repository.removeFavorite(dunaId);
    await repository.addFavorite(dunaMovie, addedAt: dunaAddedAt);

    expect((await favorites()).map((f) => f.movie.id), [matrixId, dunaId]);
  });

  test('remove o filme, e remover um que não está lá não é erro', () async {
    await repository.addFavorite(dunaMovie);
    await repository.addFavorite(matrixMovie);

    expect(await repository.removeFavorite(dunaId), isA<Ok<void>>());
    expect(await repository.removeFavorite(dunaId), isA<Ok<void>>());
    expect((await favorites()).map((f) => f.movie.id), [matrixId]);
  });

  test('falha do banco vira Error, sem lançar', () async {
    await database.close();

    expect(await repository.getFavorites(), isA<Error<List<Favorite>>>());
    expect(await repository.addFavorite(dunaMovie), isA<Error<void>>());
    expect(await repository.removeFavorite(dunaId), isA<Error<void>>());
  });
}
