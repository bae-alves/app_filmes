import 'package:app_filmes/data/repositories/ratings_repository.dart';
import 'package:app_filmes/data/repositories/ratings_repository_local.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../fakes/movie_fixtures.dart';

void main() {
  late Database database;
  late RatingsRepositoryLocal repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    // Banco novo, em memória, a cada teste: o mesmo esquema do app.
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = RatingsRepositoryLocal(database: database);
  });

  tearDown(() => database.close());

  Future<Rating?> rating(int movieId) async =>
      switch (await repository.getRating(movieId)) {
        Ok(:final value) => value,
        Error(:final error) => throw error,
      };

  test('filme sem avaliação devolve null', () async {
    expect(await rating(dunaId), isNull);
  });

  test('guarda nota e humor de cada filme', () async {
    await repository.saveRating(
      Rating(
        movieId: dunaId,
        stars: 4,
        mood: Mood.tense,
        ratedAt: DateTime.fromMillisecondsSinceEpoch(10),
      ),
    );
    await repository.saveRating(
      Rating(
        movieId: matrixId,
        stars: 5,
        ratedAt: DateTime.fromMillisecondsSinceEpoch(20),
      ),
    );

    final duna = await rating(dunaId);
    expect(duna?.stars, 4);
    expect(duna?.mood, Mood.tense);
    expect(duna?.ratedAt, DateTime.fromMillisecondsSinceEpoch(10));

    final matrix = await rating(matrixId);
    expect(matrix?.stars, 5);
    expect(matrix?.mood, isNull);
  });

  test('aceita só o humor, sem nota', () async {
    await repository.saveRating(
      Rating(movieId: dunaId, mood: Mood.loved, ratedAt: DateTime(2026)),
    );

    final duna = await rating(dunaId);
    expect(duna?.stars, isNull);
    expect(duna?.mood, Mood.loved);
  });

  test('salvar de novo troca a avaliação anterior', () async {
    await repository.saveRating(
      Rating(
        movieId: dunaId,
        stars: 2,
        mood: Mood.bored,
        ratedAt: DateTime(2026),
      ),
    );
    await repository.saveRating(
      Rating(movieId: dunaId, stars: 5, ratedAt: DateTime(2027)),
    );

    final duna = await rating(dunaId);
    expect(duna?.stars, 5);
    expect(duna?.mood, isNull);
    expect(duna?.ratedAt, DateTime(2027));
  });

  test('remove a avaliação, e remover o que não existe não é erro', () async {
    await repository.saveRating(
      Rating(movieId: dunaId, stars: 3, ratedAt: DateTime(2026)),
    );

    expect(await repository.removeRating(dunaId), isA<Ok<void>>());
    expect(await rating(dunaId), isNull);
    expect(await repository.removeRating(matrixId), isA<Ok<void>>());
  });

  test('humor que o app não conhece mais é lido como sem humor', () async {
    await database.insert(AppDatabase.ratingsTable, {
      'movie_id': dunaId,
      'stars': 3,
      'mood': 'humor-removido',
      'rated_at': 0,
    });

    final duna = await rating(dunaId);
    expect(duna?.stars, 3);
    expect(duna?.mood, isNull);

    // Sem nota, sobraria uma avaliação vazia: vira "não avaliado".
    await database.insert(AppDatabase.ratingsTable, {
      'movie_id': matrixId,
      'mood': 'humor-removido',
      'rated_at': 0,
    });
    expect(await rating(matrixId), isNull);
  });

  test('o banco recusa nota fora de 1 a 5', () async {
    expect(
      () => database.insert(AppDatabase.ratingsTable, {
        'movie_id': dunaId,
        'stars': 6,
        'rated_at': 0,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('falha do banco vira Error, sem exceção', () async {
    await database.close();

    expect(await repository.getRating(dunaId), isA<Error<Rating?>>());
    expect(
      await repository.saveRating(
        Rating(movieId: dunaId, stars: 1, ratedAt: DateTime(2026)),
      ),
      isA<Error<void>>(),
    );
    expect(await repository.removeRating(dunaId), isA<Error<void>>());
  });
}
