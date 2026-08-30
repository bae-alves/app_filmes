import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/video.dart';
import 'package:app_filmes/data/repositories/movies_repository.dart';
import 'package:app_filmes/utils/result.dart';

/// Repositório em memória usado nos testes de view model e de widget.
///
/// Substitui a implementação que fala com o TMDB, deixando os testes rápidos e
/// determinísticos. Também registra as chamadas recebidas, para que o teste
/// possa afirmar *qual* filme foi pedido.
class FakeMoviesRepository implements MoviesRepository {
  FakeMoviesRepository({
    this.popularMovies = const [],
    this.detailsById = const {},
    this.trailersById = const {},
    this.popularError,
    this.detailsError,
    this.trailerError,
  });

  /// Filmes devolvidos por [getPopularMovies].
  final List<Movie> popularMovies;

  /// Detalhes disponíveis, indexados pelo id do filme.
  final Map<int, MovieDetails> detailsById;

  /// Trailers disponíveis, indexados pelo id do filme. Ids ausentes
  /// representam filmes sem trailer publicado.
  final Map<int, Video> trailersById;

  /// Quando definido, [getPopularMovies] falha com esta exceção.
  final Exception? popularError;

  /// Quando definido, [getMovieDetails] falha com esta exceção.
  final Exception? detailsError;

  /// Quando definido, [getMovieTrailer] falha com esta exceção.
  final Exception? trailerError;

  /// Ids passados para [getMovieDetails], na ordem em que chegaram.
  final List<int> requestedDetailIds = [];

  /// Ids passados para [getMovieTrailer], na ordem em que chegaram.
  final List<int> requestedTrailerIds = [];

  /// Quantas vezes [getPopularMovies] foi chamado com `forceRefresh: true`.
  int forcedRefreshCount = 0;

  @override
  Future<Result<List<Movie>>> getPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) forcedRefreshCount++;
    final error = popularError;
    if (error != null) return Result.error(error);
    return Result.ok(popularMovies);
  }

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async {
    requestedDetailIds.add(movieId);
    final error = detailsError;
    if (error != null) return Result.error(error);

    final details = detailsById[movieId];
    if (details == null) {
      return Result.error(Exception('Filme $movieId não encontrado.'));
    }
    return Result.ok(details);
  }

  @override
  Future<Result<Video?>> getMovieTrailer(int movieId) async {
    requestedTrailerIds.add(movieId);
    final error = trailerError;
    if (error != null) return Result.error(error);
    return Result.ok(trailersById[movieId]);
  }
}
