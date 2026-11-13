import 'package:sqflite/sqflite.dart';

import '../../utils/result.dart';
import '../services/app_database.dart';
import 'ratings_repository.dart';

/// [RatingsRepository] guardado no SQLite do aparelho (veja [AppDatabase]).
class RatingsRepositoryLocal implements RatingsRepository {
  RatingsRepositoryLocal({
    required Database database,
    String? Function()? currentUserIdProvider,
  }) : _database = database,
       _currentUserIdProvider = currentUserIdProvider;

  final Database _database;
  final String? Function()? _currentUserIdProvider;

  String get _activeUserId => _currentUserIdProvider?.call() ?? 'default_user';

  @override
  Future<Result<List<Rating>>> getRatings() async {
    try {
      final rows = await _database.query(
        AppDatabase.ratingsTable,
        where: 'user_id = ?',
        whereArgs: [_activeUserId],
        orderBy: 'rated_at DESC',
      );

      return Result.ok([for (final row in rows) _ratingFromRow(row)!]);
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao carregar o histórico de avaliações ($error).'),
      );
    }
  }

  @override
  Future<Result<Rating?>> getRating(int movieId) async {
    try {
      final rows = await _database.query(
        AppDatabase.ratingsTable,
        where: 'movie_id = ? AND user_id = ?',
        whereArgs: [movieId, _activeUserId],
      );
      return Result.ok(rows.isEmpty ? null : _ratingFromRow(rows.single));
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao ler a avaliação do filme $movieId ($error).'),
      );
    }
  }

  @override
  Future<Result<void>> saveRating(Rating rating) async {
    try {
      await _database.insert(AppDatabase.ratingsTable, {
        'movie_id': rating.movieId,
        'user_id': _activeUserId,
        'stars': rating.stars,
        'mood': rating.mood?.name,
        'rated_at': rating.ratedAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao avaliar o filme ${rating.movieId} ($error).'),
      );
    }
  }

  @override
  Future<Result<void>> removeRating(int movieId) async {
    try {
      await _database.delete(
        AppDatabase.ratingsTable,
        where: 'movie_id = ? AND user_id = ?',
        whereArgs: [movieId, _activeUserId],
      );
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(
        Exception('Falha ao apagar a avaliação do filme $movieId ($error).'),
      );
    }
  }

  static Rating? _ratingFromRow(Map<String, Object?> row) {
    final stars = row['stars'] as int?;
    final mood = Mood.values.asNameMap()[row['mood']];
    if (stars == null && mood == null) return null;
    return Rating(
      movieId: row['movie_id']! as int,
      stars: stars,
      mood: mood,
      ratedAt: DateTime.fromMillisecondsSinceEpoch(row['rated_at']! as int),
    );
  }
}
