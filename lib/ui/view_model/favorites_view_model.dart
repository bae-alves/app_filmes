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

  List<Favorite> _favorites = const [];
  bool _isLoading = false;
  Exception? _error;

  /// Último favorito tirado por [remove] e a posição em que estava, para
  /// [undoRemove].
  (Favorite, int)? _lastRemoved;

  /// Filmes favoritados, do mais recente ao mais antigo.
  List<Movie> get favorites => [for (final f in _favorites) f.movie];

  /// Indica que a lista está sendo lida.
  bool get isLoading => _isLoading;

  /// Erro da última leitura da lista, ou `null`.
  Exception? get error => _error;

  /// O filme [movieId] está nos favoritos.
  bool isFavorite(int movieId) => _favorites.any((f) => f.movie.id == movieId);

  /// Lê a lista salva.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    switch (await _favoritesRepository.getFavorites()) {
      case Ok<List<Favorite>>(:final value):
        _favorites = value;
      case Error<List<Favorite>>(:final error):
        _error = error;
        if (kDebugMode) {
          debugPrint('Não foi possível carregar os favoritos: $error');
        }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona [movie] aos favoritos, ou o remove se já estiver lá.
  Future<void> toggle(Movie movie) => isFavorite(movie.id)
      ? remove(movie.id)
      : _insert(Favorite(movie: movie, addedAt: DateTime.now()), 0);

  /// Tira o filme [movieId] da lista. [undoRemove] o devolve ao mesmo lugar.
  Future<void> remove(int movieId) async {
    final index = _favorites.indexWhere((f) => f.movie.id == movieId);
    if (index < 0) return;
    _lastRemoved = (_favorites[index], index);
    await _update(
      [..._favorites]..removeAt(index),
      () => _favoritesRepository.removeFavorite(movieId),
    );
  }

  /// Desfaz o último [remove]: o filme volta à posição em que estava, com a
  /// mesma data de entrada, e por isso continua lá depois de reabrir o app.
  Future<void> undoRemove() async {
    final lastRemoved = _lastRemoved;
    _lastRemoved = null;
    if (lastRemoved == null) return;
    final (favorite, index) = lastRemoved;
    if (isFavorite(favorite.movie.id)) return;
    await _insert(favorite, index);
  }

  Future<void> _insert(Favorite favorite, int index) => _update(
    [..._favorites]..insert(index.clamp(0, _favorites.length), favorite),
    () => _favoritesRepository.addFavorite(
      favorite.movie,
      addedAt: favorite.addedAt,
    ),
  );

  /// Mostra [next] na hora e grava com [write]; se a gravação falhar, a lista
  /// volta ao que era.
  Future<void> _update(
    List<Favorite> next,
    Future<Result<void>> Function() write,
  ) async {
    final previous = _favorites;
    _favorites = next;
    notifyListeners();

    if (await write() case Error(:final error)) {
      _favorites = previous;
      notifyListeners();
      if (kDebugMode) debugPrint('Não foi possível salvar o favorito: $error');
    }
  }
}
