import '../../utils/result.dart';

/// Avaliações que o usuário dá aos filmes que já assistiu: uma nota de 1 a 5,
/// uma reação de humor, ou as duas.
///
/// Elas existem para o algoritmo de recomendação refinar as sugestões. Como a
/// lista de favoritos, hoje moram só no aparelho, em SQLite
/// (`RatingsRepositoryLocal`). Veja docs/explicacao/avaliacoes.md.
abstract class RatingsRepository {
  /// Avaliação do filme [movieId], ou `null` se ele ainda não foi avaliado.
  Future<Result<Rating?>> getRating(int movieId);

  /// Guarda [rating], trocando a avaliação anterior do mesmo filme.
  Future<Result<void>> saveRating(Rating rating);

  /// Apaga a avaliação do filme [movieId]. Apagar o que não existe não é erro.
  Future<Result<void>> removeRating(int movieId);
}

/// Avaliação de um filme. Tem ao menos a nota ou o humor.
class Rating {
  const Rating({
    required this.movieId,
    this.stars,
    this.mood,
    required this.ratedAt,
  }) : assert(stars != null || mood != null),
       assert(stars == null || (stars >= 1 && stars <= 5));

  /// Id do filme no TMDB.
  final int movieId;

  /// Nota de 1 a 5, ou `null` se o usuário só marcou o humor.
  final int? stars;

  /// Como o filme fez o usuário se sentir, ou `null` se ele só deu nota.
  final Mood? mood;

  /// Quando a avaliação mudou pela última vez.
  final DateTime ratedAt;
}

/// Reação de humor a um filme.
///
/// O [name] de cada valor é o que vai para o banco: renomear um valor apaga a
/// reação de quem já o escolheu. Para trocar o texto ou o emoji, mude só a UI.
enum Mood { loved, funny, moved, tense, bored }
