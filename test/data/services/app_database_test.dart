import 'dart:io';

import 'package:app_filmes/data/services/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory dir;

  setUpAll(sqfliteFfiInit);
  setUp(() => dir = Directory.systemTemp.createTempSync('app_database_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('quem já tinha o banco da versão 1 ganha as avaliações e mantém os '
      'favoritos', () async {
    final path = p.join(dir.path, AppDatabase.fileName);

    // O esquema da versão 1, como foi publicado no MOVIEAI-24.
    final v1 = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute('''
          CREATE TABLE favorites (
            movie_id INTEGER PRIMARY KEY,
            title TEXT,
            original_title TEXT,
            overview TEXT,
            poster_path TEXT,
            backdrop_path TEXT,
            release_date TEXT,
            vote_average REAL,
            vote_count INTEGER,
            added_at INTEGER NOT NULL
          )
        '''),
      ),
    );
    await v1.insert('favorites', {
      'movie_id': 1,
      'title': 'Duna',
      'added_at': 0,
    });
    await v1.close();

    final database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: path,
    );
    addTearDown(database.close);

    expect(await database.getVersion(), AppDatabase.version);
    expect(
      (await database.query(AppDatabase.favoritesTable)).single['title'],
      'Duna',
    );
    await database.insert(AppDatabase.ratingsTable, {
      'movie_id': 1,
      'stars': 5,
      'rated_at': 0,
    });
    expect(await database.query(AppDatabase.ratingsTable), hasLength(1));
  });
}
