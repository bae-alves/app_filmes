import 'package:app_filmes/data/repositories/ratings_repository.dart';
import 'package:app_filmes/utils/result.dart';

/// Avaliações em memória, usadas nos testes de view model e de widget.
class FakeRatingsRepository implements RatingsRepository {
  FakeRatingsRepository({
    Map<int, Rating>? ratings,
    this.readError,
    this.writeError,
  }) : ratings = ratings ?? {};

  /// Avaliações guardadas, por id do filme.
  final Map<int, Rating> ratings;

  /// Quando definido, [getRating] falha com esta exceção.
  Exception? readError;

  /// Quando definido, [saveRating] e [removeRating] falham com esta exceção.
  Exception? writeError;

  @override
  Future<Result<Rating?>> getRating(int movieId) async {
    if (readError case final error?) return Result.error(error);
    return Result.ok(ratings[movieId]);
  }

  @override
  Future<Result<void>> saveRating(Rating rating) async {
    if (writeError case final error?) return Result.error(error);
    ratings[rating.movieId] = rating;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removeRating(int movieId) async {
    if (writeError case final error?) return Result.error(error);
    ratings.remove(movieId);
    return const Result.ok(null);
  }
}
