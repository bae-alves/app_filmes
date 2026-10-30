import 'package:flutter/material.dart';

import '../../data/api_models/movie.dart';
import '../../l10n/app_localizations.dart';
import '../view_model/favorites_view_model.dart';
import 'home_page.dart';
import 'movie_details_page.dart';
import 'widgets/movie_card.dart';
import 'widgets/trailer_player.dart';

/// Lista de favoritos (watchlist): os filmes que o usuário salvou para ver
/// depois. Aberta pelo coração da AppBar da tela inicial.
///
/// Um filme sai da lista pelo botão de lixeira do cartão, arrastando o cartão
/// para a esquerda, ou pelo coração da tela de detalhes. As duas primeiras
/// formas oferecem "Desfazer". Ao voltar dos detalhes, a lista já está
/// atualizada, porque as duas telas ouvem a mesma view model.
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

  /// Quanto tempo o aviso de filme removido, com "Desfazer", fica na tela.
  static const undoDuration = Duration(seconds: 10);

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

  /// Remove [movie] e oferece desfazer.
  void _remove(Movie movie) {
    final l10n = AppLocalizations.of(context);
    widget.viewModel.remove(movie.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.favoriteRemoved(
              movie.title ?? movie.originalTitle ?? l10n.untitled,
            ),
          ),
          // Com uma ação, o SnackBar fica na tela até ser fechado; aqui ele
          // some sozinho, como é de costume para "Desfazer". Os 4s padrão
          // eram pouco para alcançar o botão no celular.
          persist: false,
          duration: FavoritesPage.undoDuration,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: widget.viewModel.undoRemove,
          ),
        ),
      );
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
              return Dismissible(
                key: ValueKey(movie.id),
                direction: DismissDirection.endToStart,
                background: const _RemoveBackground(),
                onDismissed: (_) => _remove(movie),
                child: MovieCard(
                  movie: movie,
                  onTap: () => Navigator.of(context).push(
                    MovieDetailsPage.route(
                      viewModel: widget.detailsViewModelFactory(movie.id),
                      favoritesViewModel: viewModel,
                      fallbackTitle: movie.title,
                      trailerPlayerBuilder: widget.trailerPlayerBuilder,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.favoriteRemove,
                    onPressed: () => _remove(movie),
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

/// Fundo que aparece atrás do cartão enquanto ele é arrastado para remover.
class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      // A mesma margem do MovieCard, para o fundo não vazar pelas bordas.
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
    );
  }
}
