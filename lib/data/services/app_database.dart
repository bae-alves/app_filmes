import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

/// Banco SQLite local do app.
abstract final class AppDatabase {
  static const fileName = 'app_filmes.db';

  /// Versão do esquema.
  /// 1: favoritos (MOVIEAI-24).
  /// 2: avaliações (MOVIEAI-22).
  /// 3: usuários e listas por usuário (MOVIEAI-AUTH).
  /// 4: preferências do onboarding (MOVIEAI-ONBOARDING).
  static const version = 4;

  static const favoritesTable = 'favorites';
  static const ratingsTable = 'ratings';
  static const usersTable = 'users';
  static const onboardingTable = 'user_onboarding_preferences';

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
        movie_id INTEGER NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'default_user',
        title TEXT,
        original_title TEXT,
        overview TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL,
        vote_count INTEGER,
        added_at INTEGER NOT NULL,
        PRIMARY KEY (movie_id, user_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE $ratingsTable (
        movie_id INTEGER NOT NULL,
        user_id TEXT NOT NULL DEFAULT 'default_user',
        stars INTEGER CHECK (stars BETWEEN 1 AND 5),
        mood TEXT,
        rated_at INTEGER NOT NULL,
        PRIMARY KEY (movie_id, user_id)
      )
    ''');
    await _createUsers(db);
    await _createOnboardingTable(db);
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    if (from < 2) await _createRatings(db);
    if (from < 3) {
      await _createUsers(db);
      await db.execute(
        "ALTER TABLE $favoritesTable ADD COLUMN user_id TEXT NOT NULL DEFAULT 'default_user'",
      );
      await db.execute(
        "ALTER TABLE $ratingsTable ADD COLUMN user_id TEXT NOT NULL DEFAULT 'default_user'",
      );
    }
    if (from < 4) {
      await _createOnboardingTable(db);
    }
  }

  static Future<void> _createRatings(Database db) => db.execute('''
    CREATE TABLE $ratingsTable (
      movie_id INTEGER PRIMARY KEY,
      stars INTEGER CHECK (stars BETWEEN 1 AND 5),
      mood TEXT,
      rated_at INTEGER NOT NULL
    )
  ''');

  static Future<void> _createUsers(Database db) => db.execute('''
    CREATE TABLE $usersTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT,
      auth_provider TEXT NOT NULL,
      photo_url TEXT,
      created_at INTEGER NOT NULL
    )
  ''');

  static Future<void> _createOnboardingTable(Database db) => db.execute('''
    CREATE TABLE $onboardingTable (
      user_id TEXT PRIMARY KEY,
      genres TEXT,
      actors TEXT,
      directors TEXT,
      is_completed INTEGER NOT NULL DEFAULT 0
    )
  ''');
}
