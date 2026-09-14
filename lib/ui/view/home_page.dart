import 'package:flutter/material.dart';

import '../../data/api_models/movie.dart';
import '../view_model/home_view_model.dart';
import '../view_model/movie_details_view_model.dart';
import 'movie_details_page.dart';
import 'widgets/movie_card.dart';
import 'widgets/trailer_player.dart';

/// Cria a view model da tela de detalhes de um filme.
///
/// A home não conhece repositórios: ela apenas pede a view model já montada
/// para quem a construiu (o `main.dart`, ou o teste).
typedef MovieDetailsViewModelFactory = MovieDetailsViewModel Function(
  int movieId,
);

/// Tela inicial: lista os filmes populares e leva aos detalhes de cada um.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.viewModel,
    required this.detailsViewModelFactory,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Estado e comandos da tela.
  final HomeViewModel viewModel;

  /// Fábrica da view model usada ao abrir a tela de detalhes.
  final MovieDetailsViewModelFactory detailsViewModelFactory;

  /// Repassado para a tela de detalhes. Veja [TrailerPlayerBuilder].
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Carrega uma única vez, ao montar a tela. Chamar `load()` dentro do build
    // provocaria uma nova requisição a cada reconstrução.
    widget.viewModel.load();
  }

  /// Abre a tela de detalhes do [movie] tocado.
  ///
  /// Roteamento simples como este é responsabilidade da view, segundo a
  /// arquitetura em camadas: a view model continua sem depender do Navigator.
  void _openDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: MovieDetailsPage.routeName),
        builder: (_) => MovieDetailsPage(
          viewModel: widget.detailsViewModelFactory(movie.id),
          fallbackTitle: movie.title,
          trailerPlayerBuilder: widget.trailerPlayerBuilder,
        ),
      ),
    );
  }
Future<void> _openAdvancedFilter() async {
  await widget.viewModel.loadGenres();

  if (!mounted) return;

  showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;

          if (viewModel.isLoadingGenres) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (viewModel.genresError != null) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: Text('Não foi possível carregar os gêneros.'),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Filtro avançado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.genres.length,
                    itemBuilder: (context, index) {
                      final genre = viewModel.genres[index];

                      return CheckboxListTile(
                        title: Text(genre.name),
                        value: viewModel.selectedGenreIds.contains(
                          genre.id,
                        ),
                        onChanged: (_) {
                          viewModel.toggleGenre(genre.id);
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await viewModel.applyGenreFilter();

                        if (!context.mounted) return;

                        Navigator.of(context).pop();
                      },
                      child: const Text('Aplicar filtros'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filmes populares')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;

          if (viewModel.isLoading && viewModel.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = viewModel.error;
          if (error != null) {
            return _ErrorState(
              message: error.toString(),
              onRetry: () => viewModel.load(forceRefresh: true),
            );
          }

          if (viewModel.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      labelText: 'Nome do filme',
                      hintText: 'Digite o nome do filme',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _search,
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune),
                            tooltip: 'Filtro avançado',
                            onPressed: _openAdvancedFilter,
                          ),
                        ],
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Nenhum filme encontrado no momento.'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    labelText: 'Nome do filme',
                    hintText: 'Digite o nome do filme',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _search,
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          tooltip: 'Filtro avançado',
                          onPressed: _openAdvancedFilter,
                        ),
                      ],
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
            onRefresh: () => viewModel.load(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: viewModel.movies.length,
              itemBuilder: (context, index) {
                final movie = viewModel.movies[index];
                return MovieCard(
                  key: ValueKey(movie.id),
                  movie: movie,
                  onTap: () => _openDetails(movie),
                );
              },
            ),
          ),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    widget.viewModel.search(_searchController.text);
  }
}

/// Estado de erro com opção de tentar novamente.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
