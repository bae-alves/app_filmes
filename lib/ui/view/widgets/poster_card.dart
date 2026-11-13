import 'package:flutter/material.dart';

import '../../../data/api_models/movie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/formatters.dart';
import '../../../utils/tmdb_images.dart';
import '../../view_model/favorites_view_model.dart';

/// Cartão de pôster da grade da tela inicial: pôster com a nota e o botão de
/// favorito por cima, e título e ano embaixo.
///
/// Como o [MovieCard], não conhece repositório nem navegação: quem decide o
/// que o toque faz é a página.
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.movie,
    required this.favoritesViewModel,
    required this.onTap,
  });

  final Movie movie;

  /// Liga e desliga o favorito pelo botão no canto do pôster.
  final FavoritesViewModel favoritesViewModel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final rating = formatRating(
      movie.voteAverage,
      Localizations.localeOf(context).toString(),
    );
    final year = formatReleaseYear(movie.releaseDate);
    final posterUrl = TmdbImages.poster(movie.posterPath);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  posterUrl == null
                      ? const _PosterPlaceholder(icon: Icons.movie_outlined)
                      : Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          // Sem isso, a imagem quebrada derrubaria o cartão.
                          errorBuilder: (context, error, stackTrace) =>
                              const _PosterPlaceholder(
                                icon: Icons.broken_image_outlined,
                              ),
                        ),
                  if (rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _RatingBadge(rating: rating),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _FavoriteToggle(
                      movie: movie,
                      favoritesViewModel: favoritesViewModel,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? movie.originalTitle ?? l10n.untitled,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (year != null)
                    Text(
                      year,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(icon),
  );
}

/// Nota do TMDB sobre o pôster, num fundo escuro para ler sobre qualquer
/// imagem.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 2),
          Text(
            rating,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({
    required this.movie,
    required this.favoritesViewModel,
  });

  final Movie movie;
  final FavoritesViewModel favoritesViewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: favoritesViewModel,
      builder: (context, _) {
        final isFavorite = favoritesViewModel.isFavorite(movie.id);
        return IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.6),
            foregroundColor: Colors.white,
          ),
          isSelected: isFavorite,
          icon: const Icon(Icons.favorite_border, size: 20),
          selectedIcon: Icon(
            Icons.favorite,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
          onPressed: () => favoritesViewModel.toggle(movie),
        );
      },
    );
  }
}
