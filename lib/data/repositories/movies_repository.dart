import '../../utils/result.dart';
import '../api_models/movie.dart';
import '../api_models/movie_details.dart';
import '../api_models/video.dart';

/// Fonte única da verdade sobre filmes para a aplicação.
///
/// A interface existe para que a camada de UI dependa de uma abstração, e não
/// de uma implementação concreta: em produção usamos
/// `MoviesRepositoryRemote` (TMDB) e, nos testes, um fake em memória.
abstract class MoviesRepository {
  /// Filmes populares da página [page].
  ///
  /// O resultado pode vir de cache; passe [forceRefresh] para ignorá-lo, por
  /// exemplo quando o usuário faz "puxar para atualizar".
  Future<Result<List<Movie>>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  });

  /// Detalhes do filme [movieId].
  Future<Result<MovieDetails>> getMovieDetails(int movieId);

  /// Melhor trailer disponível para o filme [movieId].
  ///
  /// O sucesso com valor `null` é legítimo e diferente de erro: significa que
  /// a requisição funcionou, mas o filme não tem trailer publicado.
  Future<Result<Video?>> getMovieTrailer(int movieId);
}
