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
            return const Center(
              child: Text('Nenhum filme encontrado no momento.'),
            );
          }

          return RefreshIndicator(
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
          );
        },
      ),
    );
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
