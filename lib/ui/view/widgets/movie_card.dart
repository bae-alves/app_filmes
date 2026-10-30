import 'package:flutter/material.dart';

import '../../../data/api_models/movie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/formatters.dart';
import '../../../utils/tmdb_images.dart';

/// Cartão de um filme na lista da tela inicial.
///
/// É um widget "burro": recebe o modelo e um callback, e não conhece nem
/// repositório nem navegação. Quem decide o que acontece no toque é a página.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.trailing,
  });

  /// Filme exibido pelo cartão.
  final Movie movie;

  /// Chamado quando o usuário toca no cartão.
  final VoidCallback onTap;

  /// Widget no canto superior direito, como o botão de remover dos favoritos.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = formatReleaseYear(movie.releaseDate);
    final l10n = AppLocalizations.of(context);
    final rating = formatRating(
      movie.voteAverage,
      Localizations.localeOf(context).toString(),
    );
    final posterUrl = TmdbImages.poster(movie.posterPath, size: 'w185');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Poster(url: posterUrl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title ?? movie.originalTitle ?? l10n.untitled,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (rating != null) ...[
                            Icon(Icons.star_rounded,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 2),
                            Text(rating, style: theme.textTheme.labelMedium),
                          ],
                          if (rating != null && year != null)
                            const SizedBox(width: 12),
                          if (year != null)
                            Text(year, style: theme.textTheme.labelMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          movie.overview?.isNotEmpty == true
                              ? movie.overview!
                              : l10n.synopsisUnavailable,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (trailing != null)
                Align(alignment: Alignment.topCenter, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pôster do cartão, com placeholder para filmes sem imagem cadastrada.
class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const width = 100.0;
    if (url == null) {
      return Container(
        width: width,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.movie_outlined),
      );
    }

    return Image.network(
      url!,
      width: width,
      fit: BoxFit.cover,
      // Sem tratamento de erro a imagem quebrada estouraria uma exceção de
      // renderização e derrubaria o item inteiro da lista.
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
