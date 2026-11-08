import 'package:flutter/foundation.dart';

import '../../data/repositories/ratings_repository.dart';
import '../../utils/result.dart';

/// Avaliação que o usuário dá a um filme: nota de 1 a 5 e reação de humor.
///
/// Há uma por tela de detalhes, criada pela fábrica do `main.dart`.
class MovieRatingViewModel extends ChangeNotifier {
  MovieRatingViewModel({
    required RatingsRepository ratingsRepository,
    required this.movieId,
  }) : _ratingsRepository = ratingsRepository;

  final RatingsRepository _ratingsRepository;

  /// Id do filme avaliado.
  final int movieId;

  Rating? _rating;
  bool _disposed = false;

  /// Nota de 1 a 5, ou `null` sem nota.
  int? get stars => _rating?.stars;

  /// Reação de humor, ou `null` sem reação.
  Mood? get mood => _rating?.mood;

  /// Lê a avaliação salva. Se a leitura falhar, a tela mostra o filme como
  /// ainda não avaliado.
  Future<void> load() async {
    switch (await _ratingsRepository.getRating(movieId)) {
      case Ok<Rating?>(:final value):
        _rating = value;
      case Error<Rating?>(:final error):
        if (kDebugMode) {
          debugPrint(
            'Não foi possível ler a avaliação do filme $movieId: $error',
          );
        }
    }
    notifyListeners();
  }

  /// Dá a nota [stars] ao filme. Escolher a nota que já está marcada a tira.
  Future<void> setStars(int stars) =>
      _update(stars: stars == this.stars ? null : stars, mood: mood);

  /// Marca a reação [mood]. Escolher a que já está marcada a tira.
  Future<void> setMood(Mood mood) =>
      _update(stars: stars, mood: mood == this.mood ? null : mood);

  /// Mostra a avaliação nova na hora e grava; se a gravação falhar, volta ao
  /// que era. Sem nota e sem humor, a avaliação é apagada.
  Future<void> _update({required int? stars, required Mood? mood}) async {
    final previous = _rating;
    final next = (stars == null && mood == null)
        ? null
        : Rating(
            movieId: movieId,
            stars: stars,
            mood: mood,
            ratedAt: DateTime.now(),
          );
    _rating = next;
    notifyListeners();

    final result = next == null
        ? await _ratingsRepository.removeRating(movieId)
        : await _ratingsRepository.saveRating(next);
    if (result case Error(:final error)) {
      _rating = previous;
      notifyListeners();
      if (kDebugMode) debugPrint('Não foi possível salvar a avaliação: $error');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// A tela pode fechar antes de uma leitura ou gravação terminar; aí não há
  /// mais quem avisar.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
