import 'package:flutter/foundation.dart';

import '../../data/api_models/movie.dart';
import '../../data/repositories/movies_repository.dart';
import '../../utils/result.dart';
import '../../data/api_models/movie_genre.dart';

/// View model da tela inicial: mantém o estado da lista de filmes populares.
///
/// Ela não sabe nada sobre widgets — expõe estado e comandos, e avisa a view
/// através de [notifyListeners]. É o "UI = f(state)" na prática.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required MoviesRepository moviesRepository})
      : _moviesRepository = moviesRepository;

  final MoviesRepository _moviesRepository;

  List<Movie> _movies = const [];
  List<MovieGenre> _genres = const [];

  bool _isLoading = false;
  bool _isLoadingGenres = false;

  Exception? _error;
  Exception? _genresError;

  String _searchQuery = '';
  List<int> _selectedGenreIds = const [];
  /// Filmes exibidos na lista. Vazio enquanto o primeiro carregamento não
  /// termina ou quando ocorre erro.
  List<Movie> get movies => List.unmodifiable(_movies);

  /// Gêneros disponíveis para o filtro avançado.
  List<MovieGenre> get genres => List.unmodifiable(_genres);

  /// Indica que há uma requisição em andamento.
  bool get isLoading => _isLoading;

  /// Indica que os gêneros estão sendo carregados.
  bool get isLoadingGenres => _isLoadingGenres;

  /// Erro do último carregamento, ou `null` se deu tudo certo.
  Exception? get error => _error;

  /// Erro relacionado ao carregamento dos gêneros.
  Exception? get genresError => _genresError;

  /// Texto atualmente utilizado na pesquisa.
  String get searchQuery => _searchQuery;

  /// IDs dos gêneros atualmente selecionados.
  List<int> get selectedGenreIds => List.unmodifiable(_selectedGenreIds);

  /// Indica se existe algum filtro ativo.
  bool get hasFilters =>
      _searchQuery.trim().isNotEmpty || _selectedGenreIds.isNotEmpty;

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
  /// Pesquisa filmes pelo nome.
  Future<Result<List<Movie>>> search(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      _searchQuery = '';
      return load();
    }

    _searchQuery = normalizedQuery;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _moviesRepository.searchMovies(
      query: normalizedQuery,
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

  /// Seleciona ou remove um gênero do filtro.
  void toggleGenre(int genreId) {
    final selected = List<int>.from(_selectedGenreIds);

    if (selected.contains(genreId)) {
      selected.remove(genreId);
    } else {
      selected.add(genreId);
    }

    _selectedGenreIds = selected;
    notifyListeners();
  }

  /// Aplica os gêneros selecionados.
  Future<Result<List<Movie>>> applyGenreFilter() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _moviesRepository.discoverMovies(
      genreIds: _selectedGenreIds,
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

  /// Carrega a lista de gêneros fornecida pelo TMDB.
  Future<Result<List<MovieGenre>>> loadGenres() async {
    if (_genres.isNotEmpty) {
      return Result.ok(_genres);
    }

    _isLoadingGenres = true;
    _genresError = null;
    notifyListeners();

    final result = await _moviesRepository.getMovieGenres();

    switch (result) {
      case Ok<List<MovieGenre>>(:final value):
        _genres = value;
      case Error<List<MovieGenre>>(:final error):
        _genres = const [];
        _genresError = error;
    }

    _isLoadingGenres = false;
    notifyListeners();
    return result;
  }

  /// Limpa todos os filtros e volta para os filmes populares.
  Future<Result<List<Movie>>> clearFilters() async {
    _searchQuery = '';
    _selectedGenreIds = const [];

    return load();
  }
}
