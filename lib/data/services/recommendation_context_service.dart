import '../models/recommendation_context.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/movies_repository.dart';
import '../repositories/ratings_repository.dart';
import '../../utils/result.dart';

class RecommendationContextService {
  RecommendationContextService({
    required FavoritesRepository favoritesRepository,
    required RatingsRepository ratingsRepository,
    required MoviesRepository moviesRepository,
    DateTime Function()? now,
  }) : _favoritesRepository = favoritesRepository,
       _ratingsRepository = ratingsRepository,
       _moviesRepository = moviesRepository,
       _now = now ?? DateTime.now;

  final FavoritesRepository _favoritesRepository;
  final RatingsRepository _ratingsRepository;
  final MoviesRepository _moviesRepository;
  final DateTime Function() _now;

  Future<RecommendationContext> build() async {
    final favoritesResult = await _favoritesRepository.getFavorites();
    final ratingsResult = await _ratingsRepository.getRatings();

    final favorites = switch (favoritesResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    final ratings = switch (ratingsResult) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    // Evita consultar o mesmo filme duas vezes.
    final movieIds = <int>{
      ...favorites.map((favorite) => favorite.movie.id),
      ...ratings.map((rating) => rating.movieId),
    };

    // Busca os detalhes para descobrir os gêneros de cada filme.
    final detailsResults = await Future.wait(
      movieIds.map((id) => _moviesRepository.getMovieDetails(id)),
    );

    final genresByMovie = <int, List<String>>{};

    for (var i = 0; i < movieIds.length; i++) {
      switch (detailsResults[i]) {
        case Ok(:final value):
          genresByMovie[value.id] = [
            for (final genre in value.genres ?? [])
              if (genre.name != null && genre.name!.isNotEmpty) genre.name!,
          ];
        case Error():
          // Um detalhe indisponível não impede as demais recomendações.
          continue;
      }
    }

    // Calcula o peso de cada gênero.
    final genreScores = <String, double>{};

    void addGenreWeight(List<String> genres, double weight) {
      for (final genre in genres) {
        genreScores.update(
          genre,
          (current) => current + weight,
          ifAbsent: () => weight,
        );
      }
    }

    // Favoritos indicam interesse positivo.
    for (final favorite in favorites) {
      addGenreWeight(genresByMovie[favorite.movie.id] ?? [], 1);
    }

    // Avaliações positivas e negativas ajustam a preferência.
    for (final rating in ratings) {
      final starsWeight = switch (rating.stars) {
        5 => 2.0,
        4 => 1.0,
        3 => 0.0,
        2 => -1.0,
        1 => -2.0,
        _ => 0.0,
      };

      addGenreWeight(genresByMovie[rating.movieId] ?? [], starsWeight);
    }

    final sortedGenres = genreScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final favoriteGenres = sortedGenres
        .where((entry) => entry.value > 0)
        .take(5)
        .map((entry) => entry.key)
        .toList();

    final dislikedGenres = sortedGenres
        .where((entry) => entry.value < 0)
        .take(5)
        .map((entry) => entry.key)
        .toList();

    // Histórico recente: até cinco avaliações.
    final recentRatings = ratings.take(5).map((rating) {
      final genres = genresByMovie[rating.movieId] ?? [];
      final stars = rating.stars == null ? 'Sem nota' : '${rating.stars}/5';
      final mood = rating.mood?.name ?? 'Sem reação';
      final genreText = genres.isEmpty
          ? 'Gêneros desconhecidos'
          : genres.join(', ');

      return '$genreText - $stars - $mood';
    }).toList();

    final now = _now();

    return RecommendationContext(
      favoriteGenres: favoriteGenres,
      dislikedGenres: dislikedGenres,
      recentRatings: recentRatings,
      weekday: _weekdayName(now.weekday),
      timeOfDay: _timeOfDay(now.hour),
      currentHour: now.hour,
    );
  }

  String _weekdayName(int weekday) {
    const days = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    return days[weekday - 1];
  }

  String _timeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'manhã';
    if (hour >= 12 && hour < 18) return 'tarde';
    if (hour >= 18 && hour < 24) return 'noite';
    return 'madrugada';
  }
}
