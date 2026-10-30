import 'package:flutter/foundation.dart';

import '../../data/api_models/movie.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../utils/result.dart';

/// Estado da lista de favoritos (watchlist).
///
/// Há uma só instância no app, criada no `main.dart`: a tela de favoritos lê a
/// lista e a tela de detalhes liga e desliga o coração do filme. Como as duas
/// ouvem o mesmo objeto, favoritar num lugar aparece no outro sem recarregar.
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({required FavoritesRepository favoritesRepository})
    : _favoritesRepository = favoritesRepository;

  final FavoritesRepository _favoritesRepository;

  List<Movie> _favorites = const [];
  bool _isLoading = false;
  Exception? _error;

  /// Filmes favoritados, do mais recente ao mais antigo.
  List<Movie> get favorites => _favorites;

  /// Indica que a lista está sendo lida.
  bool get isLoading => _isLoading;

  /// Erro da última leitura da lista, ou `null`.
  Exception? get error => _error;

  /// O filme [movieId] está nos favoritos.
  bool isFavorite(int movieId) => _favorites.any((m) => m.id == movieId);

  /// Lê a lista salva.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _favoritesRepository.getFavorites()) {
      case Ok<List<Movie>>(:final value):
        _favorites = value;
      case Error<List<Movie>>(:final error):
        _error = error;
        if (kDebugMode) {
          debugPrint('Não foi possível carregar os favoritos: $error');
        }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona [movie] aos favoritos, ou o remove se já estiver lá.
  ///
  /// O coração muda na hora; se a gravação falhar, a lista volta ao que era.
  Future<void> toggle(Movie movie) async {
    final previous = _favorites;
    final remove = isFavorite(movie.id);
    _favorites = remove
        ? [
            for (final m in previous)
              if (m.id != movie.id) m,
          ]
        : [movie, ...previous];
    notifyListeners();

    final result = remove
        ? await _favoritesRepository.removeFavorite(movie.id)
        : await _favoritesRepository.addFavorite(movie);
    if (result case Error(:final error)) {
      _favorites = previous;
      notifyListeners();
      if (kDebugMode) debugPrint('Não foi possível salvar o favorito: $error');
    }
  }
}
