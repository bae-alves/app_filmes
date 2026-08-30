import 'package:flutter/foundation.dart';

import '../../data/api_models/movie.dart';
import '../../data/repositories/movies_repository.dart';
import '../../utils/result.dart';

/// View model da tela inicial: mantém o estado da lista de filmes populares.
///
/// Ela não sabe nada sobre widgets — expõe estado e comandos, e avisa a view
/// através de [notifyListeners]. É o "UI = f(state)" na prática.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required MoviesRepository moviesRepository})
      : _moviesRepository = moviesRepository;

  final MoviesRepository _moviesRepository;

  List<Movie> _movies = const [];
  bool _isLoading = false;
  Exception? _error;

  /// Filmes exibidos na lista. Vazio enquanto o primeiro carregamento não
  /// termina ou quando ocorre erro.
  List<Movie> get movies => List.unmodifiable(_movies);

  /// Indica que há uma requisição em andamento.
  bool get isLoading => _isLoading;

  /// Erro do último carregamento, ou `null` se deu tudo certo.
  Exception? get error => _error;

  /// Verdadeiro quando o carregamento terminou sem erro e sem nenhum filme.
  bool get isEmpty => !_isLoading && _error == null && _movies.isEmpty;

  /// Comando disparado pela view para carregar (ou recarregar) a lista.
  ///
  /// Devolve o [Result] para quem quiser reagir ao desfecho — por exemplo, um
  /// `RefreshIndicator` que precisa mostrar uma mensagem em caso de falha.
  Future<Result<List<Movie>>> load({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _moviesRepository.getPopularMovies(
      forceRefresh: forceRefresh,
    );

    switch (result) {
      case Ok<List<Movie>>(:final value):
        _movies = value;
      case Error<List<Movie>>(:final error):
        _movies = const [];
        _error = error;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
