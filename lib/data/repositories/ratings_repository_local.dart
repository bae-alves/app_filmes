import 'package:sqflite/sqflite.dart';

import '../../utils/result.dart';
import '../services/app_database.dart';
import 'ratings_repository.dart';

/// [RatingsRepository] guardado no SQLite do aparelho (veja [AppDatabase]).
///
/// Guarda só o id do filme: quem for usar as avaliações (o algoritmo de
/// recomendação) busca os dados do filme no TMDB.
class RatingsRepositoryLocal implements RatingsRepository {
  RatingsRepositoryLocal({required Database database}) : _database = database;

  final Database _database;

  @override
  Future<Result<Rating?>> getRating(int movieId) async {
    try {
      final rows = await _database.query(
        AppDatabase.ratingsTable,
        where: 'movie_id = ?',
        whereArgs: [movieId],
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
        where: 'movie_id = ?',
        whereArgs: [movieId],
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
    // Um humor que o app não tem mais vira "sem humor", em vez de erro.
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
