import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

/// Banco SQLite local do app.
///
/// Guarda a lista de favoritos (veja `FavoritesRepositoryLocal`) e as
/// avaliações dos filmes (veja `RatingsRepositoryLocal`). Mudanças de esquema
/// entram como uma nova [version] com um `onUpgrade`, nunca editando o
/// `CREATE TABLE` de uma versão já publicada.
abstract final class AppDatabase {
  /// Nome do arquivo do banco (no Android) ou da base no IndexedDB (na web).
  static const fileName = 'app_filmes.db';

  /// Versão do esquema. 1: favoritos (MOVIEAI-24). 2: avaliações (MOVIEAI-22).
  static const version = 2;

  /// Tabela de favoritos.
  static const favoritesTable = 'favorites';

  /// Tabela de avaliações.
  static const ratingsTable = 'ratings';

  /// Abre (criando, se preciso) o banco do app.
  ///
  /// No Android usa o sqflite nativo. Na web usa o `sqflite_common_ffi_web`,
  /// que roda o SQLite em WebAssembly e persiste no IndexedDB — por isso
  /// `web/sqlite3.wasm` e `web/sqflite_sw.js` precisam existir (veja
  /// docs/explicacao/plataformas.md).
  ///
  /// [factory] e [path] existem para os testes, que abrem um banco em memória
  /// com o `sqflite_common_ffi`.
  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory =
        factory ?? (kIsWeb ? databaseFactoryFfiWeb : databaseFactory);
    final dbPath =
        path ??
        (kIsWeb
            ? fileName
            : p.join(await dbFactory.getDatabasesPath(), fileName));

    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $favoritesTable (
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
    ''');
    await _createRatings(db);
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    if (from < 2) await _createRatings(db);
  }

  /// Versão 2. `stars` e `mood` podem ser nulos, mas não os dois: o
  /// repositório apaga a linha em vez de gravar uma avaliação vazia.
  static Future<void> _createRatings(Database db) => db.execute('''
    CREATE TABLE $ratingsTable (
      movie_id INTEGER PRIMARY KEY,
      stars INTEGER CHECK (stars BETWEEN 1 AND 5),
      mood TEXT,
      rated_at INTEGER NOT NULL
    )
  ''');
}
