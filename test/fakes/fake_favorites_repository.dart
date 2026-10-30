import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/repositories/favorites_repository.dart';
import 'package:app_filmes/utils/result.dart';

/// Lista de favoritos em memória, usada nos testes de view model e de widget.
///
/// Mantém a mesma ordem do repositório real: o adicionado por último primeiro.
class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository({
    List<Movie> favorites = const [],
    this.readError,
    this.writeError,
  }) : favorites = [...favorites];

  /// Favoritos guardados, do mais recente ao mais antigo.
  final List<Movie> favorites;

  /// Quando definido, [getFavorites] falha com esta exceção.
  Exception? readError;

  /// Quando definido, [addFavorite] e [removeFavorite] falham com esta exceção.
  Exception? writeError;

  @override
  Future<Result<List<Movie>>> getFavorites() async {
    if (readError case final error?) return Result.error(error);
    return Result.ok([...favorites]);
  }

  @override
  Future<Result<void>> addFavorite(Movie movie) async {
    if (writeError case final error?) return Result.error(error);
    favorites
      ..removeWhere((m) => m.id == movie.id)
      ..insert(0, movie);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removeFavorite(int movieId) async {
    if (writeError case final error?) return Result.error(error);
    favorites.removeWhere((m) => m.id == movieId);
    return const Result.ok(null);
  }
}
