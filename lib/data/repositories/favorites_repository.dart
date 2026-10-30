import '../../utils/result.dart';
import '../api_models/movie.dart';

/// Lista de favoritos (watchlist) do usuário.
///
/// Hoje o app não tem login, então a lista mora só no aparelho, em SQLite
/// (`FavoritesRepositoryLocal`). Quando houver autenticação, a lista poderá
/// ser salva também num endpoint da conta do usuário, e o SQLite continua como
/// cache local: a lista abre na hora e sem rede, e a sincronização acontece por
/// trás. A UI não muda, porque depende só deste contrato. Veja
/// docs/explicacao/favoritos.md.
abstract class FavoritesRepository {
  /// Filmes favoritados, do adicionado mais recentemente ao mais antigo.
  Future<Result<List<Movie>>> getFavorites();

  /// Adiciona [movie] aos favoritos. Adicionar um filme que já está na lista
  /// atualiza os dados guardados e o leva para o topo.
  Future<Result<void>> addFavorite(Movie movie);

  /// Remove o filme [movieId] dos favoritos. Remover um filme que não está na
  /// lista não é erro.
  Future<Result<void>> removeFavorite(int movieId);
}
