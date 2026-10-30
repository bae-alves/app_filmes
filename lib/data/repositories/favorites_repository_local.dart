import 'package:sqflite/sqflite.dart';

import '../../utils/result.dart';
import '../api_models/movie.dart';
import '../services/app_database.dart';
import 'favorites_repository.dart';

/// [FavoritesRepository] guardado no SQLite do aparelho (veja [AppDatabase]).
///
/// Cada favorito guarda o resumo do filme (o mesmo da listagem do TMDB), e não
/// só o id: assim a lista aparece sem nenhuma requisição, até offline.
class FavoritesRepositoryLocal implements FavoritesRepository {
  FavoritesRepositoryLocal({
    required Database database,
    DateTime Function()? now,
  }) : _database = database,
       _now = now ?? DateTime.now;

  final Database _database;

  /// Relógio usado em `added_at`. Injetável para os testes controlarem a ordem.
  final DateTime Function() _now;

  @override
  Future<Result<List<Movie>>> getFavorites() async {
    try {
      final rows = await _database.query(
        AppDatabase.favoritesTable,
        orderBy: 'added_at DESC',
      );
      return Result.ok([for (final row in rows) _movieFromRow(row)]);
    } on Exception catch (error) {
      return Result.error(Exception('Falha ao ler os favoritos ($error).'));
    }
  }

  @override
  Future<Result<void>> addFavorite(Movie movie) async {
    try {
      await _database.insert(AppDatabase.favoritesTable, {
        'movie_id': movie.id,
        'title': movie.title,
        'original_title': movie.originalTitle,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'backdrop_path': movie.backdropPath,
        'release_date': movie.releaseDate,
        'vote_average': movie.voteAverage,
        'vote_count': movie.voteCount,
        'added_at': _now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao favoritar o filme ${movie.id} ($error).'),
      );
    }
  }

  @override
  Future<Result<void>> removeFavorite(int movieId) async {
    try {
      await _database.delete(
        AppDatabase.favoritesTable,
        where: 'movie_id = ?',
        whereArgs: [movieId],
      );
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao desfavoritar o filme $movieId ($error).'),
      );
    }
  }

  static Movie _movieFromRow(Map<String, Object?> row) => Movie(
    id: row['movie_id']! as int,
    title: row['title'] as String?,
    originalTitle: row['original_title'] as String?,
    overview: row['overview'] as String?,
    posterPath: row['poster_path'] as String?,
    backdropPath: row['backdrop_path'] as String?,
    releaseDate: row['release_date'] as String?,
    voteAverage: (row['vote_average'] as num?)?.toDouble(),
    voteCount: row['vote_count'] as int?,
  );
}
