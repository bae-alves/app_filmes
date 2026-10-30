import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../view_model/favorites_view_model.dart';
import 'home_page.dart';
import 'movie_details_page.dart';
import 'widgets/movie_card.dart';
import 'widgets/trailer_player.dart';

/// Lista de favoritos (watchlist): os filmes que o usuário salvou para ver
/// depois. Aberta pelo coração da AppBar da tela inicial.
///
/// Tirar um filme da lista é pelo coração da tela de detalhes; ao voltar, a
/// lista já está atualizada, porque as duas telas ouvem a mesma view model.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.viewModel,
    required this.detailsViewModelFactory,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Estado e comandos da lista.
  final FavoritesViewModel viewModel;

  /// Fábrica da view model usada ao abrir a tela de detalhes.
  final MovieDetailsViewModelFactory detailsViewModelFactory;

  /// Repassado para a tela de detalhes. Veja [TrailerPlayerBuilder].
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Lê de novo ao abrir: a primeira leitura, no main.dart, pode ter falhado.
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;
          final favorites = viewModel.favorites;

          if (viewModel.isLoading && favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(l10n.favoritesLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: viewModel.load,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.favoritesEmpty, textAlign: TextAlign.center),
              ),
            );
          }

          return ListView.builder(
            // Padding explícito desliga o recuo automático do sistema: sem
            // somá-lo, o fim da lista fica sob a barra de navegação.
            padding:
                const EdgeInsets.symmetric(vertical: 8) +
                MediaQuery.paddingOf(context),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final movie = favorites[index];
              return MovieCard(
                key: ValueKey(movie.id),
                movie: movie,
                onTap: () => Navigator.of(context).push(
                  MovieDetailsPage.route(
                    viewModel: widget.detailsViewModelFactory(movie.id),
                    favoritesViewModel: viewModel,
                    fallbackTitle: movie.title,
                    trailerPlayerBuilder: widget.trailerPlayerBuilder,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
