import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/repositories/favorites_repository.dart';
import 'package:app_filmes/utils/result.dart';

/// Lista de favoritos em memória, usada nos testes de view model e de widget.
///
/// Mantém a mesma ordem do repositório real: do `addedAt` mais recente ao mais
/// antigo.
class FakeFavoritesRepository implements FavoritesRepository {
  /// [movies] já vem na ordem da lista: o primeiro é o mais recente.
  FakeFavoritesRepository({
    List<Movie> movies = const [],
    this.readError,
    this.writeError,
  }) : favorites = [
         for (var i = 0; i < movies.length; i++)
           Favorite(
             movie: movies[i],
             addedAt: DateTime(2026).subtract(Duration(days: i)),
           ),
       ];

  /// Favoritos guardados, do mais recente ao mais antigo.
  final List<Favorite> favorites;

  /// Ids dos filmes guardados, na ordem da lista.
  List<int> get movieIds => [for (final f in favorites) f.movie.id];

  /// Quando definido, [getFavorites] falha com esta exceção.
  Exception? readError;

  /// Quando definido, [addFavorite] e [removeFavorite] falham com esta exceção.
  Exception? writeError;

  @override
  Future<Result<List<Favorite>>> getFavorites() async {
    if (readError case final error?) return Result.error(error);
    return Result.ok([...favorites]);
  }

  @override
  Future<Result<void>> addFavorite(Movie movie, {DateTime? addedAt}) async {
    if (writeError case final error?) return Result.error(error);
    favorites
      ..removeWhere((f) => f.movie.id == movie.id)
      ..add(Favorite(movie: movie, addedAt: addedAt ?? DateTime.now()))
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removeFavorite(int movieId) async {
    if (writeError case final error?) return Result.error(error);
    favorites.removeWhere((f) => f.movie.id == movieId);
    return const Result.ok(null);
  }
}
