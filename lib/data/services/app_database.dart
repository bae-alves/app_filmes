import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

/// Banco SQLite local do app.
///
/// Hoje guarda só a lista de favoritos (veja `FavoritesRepositoryLocal`).
/// Mudanças de esquema entram como uma nova [version] com um `onUpgrade`,
/// nunca editando o `CREATE TABLE` de uma versão já publicada.
abstract final class AppDatabase {
  /// Nome do arquivo do banco (no Android) ou da base no IndexedDB (na web).
  static const fileName = 'app_filmes.db';

  /// Versão do esquema.
  static const version = 1;

  /// Tabela de favoritos.
  static const favoritesTable = 'favorites';

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
      options: OpenDatabaseOptions(version: version, onCreate: _onCreate),
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
  }
}
