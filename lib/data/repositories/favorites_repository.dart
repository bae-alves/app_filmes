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
  /// Favoritos, do adicionado mais recentemente ao mais antigo.
  Future<Result<List<Favorite>>> getFavorites();

  /// Adiciona [movie] aos favoritos. Adicionar um filme que já está na lista
  /// atualiza os dados guardados.
  ///
  /// [addedAt] (padrão: agora) define a posição do filme na lista. "Desfazer"
  /// passa o valor original, para o filme voltar ao lugar onde estava.
  Future<Result<void>> addFavorite(Movie movie, {DateTime? addedAt});

  /// Remove o filme [movieId] dos favoritos. Remover um filme que não está na
  /// lista não é erro.
  Future<Result<void>> removeFavorite(int movieId);
}

/// Um filme da lista de favoritos e o momento em que ele entrou nela.
class Favorite {
  const Favorite({required this.movie, required this.addedAt});

  /// Resumo do filme, no formato da listagem do TMDB.
  final Movie movie;

  /// Quando o filme foi favoritado. É o que ordena a lista.
  final DateTime addedAt;
}
