import 'package:flutter/material.dart';

import '../../data/api_models/genre.dart';
import '../../utils/formatters.dart';
import '../../utils/tmdb_images.dart';
import '../view_model/movie_details_view_model.dart';
import 'widgets/trailer_player.dart';

/// Tela de detalhes: mostra o trailer e as informações completas do filme.
///
/// É alcançada ao tocar em um cartão da tela inicial.
class MovieDetailsPage extends StatefulWidget {
  const MovieDetailsPage({
    super.key,
    required this.viewModel,
    this.fallbackTitle,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Identificador da rota, útil em testes e em navegação nomeada.
  static const routeName = '/movie-details';

  /// Chave do bloco que hospeda o player do trailer.
  static const trailerKey = Key('movie-details-trailer');

  /// Chave do bloco exibido quando o filme não tem trailer publicado.
  static const emptyTrailerKey = Key('movie-details-trailer-empty');

  /// Estado e comandos da tela.
  final MovieDetailsViewModel viewModel;

  /// Título já conhecido pela tela anterior. Evita uma AppBar vazia enquanto os
  /// detalhes ainda estão sendo carregados.
  final String? fallbackTitle;

  /// Como construir o player do trailer. Veja [TrailerPlayerBuilder].
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    // O carregamento é disparado uma única vez, aqui, e não no build: build
    // pode ser chamado várias vezes e dispararia requisições em cascata.
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        final details = viewModel.details;

        return Scaffold(
          appBar: AppBar(
            title: Text(details?.title ?? widget.fallbackTitle ?? 'Detalhes'),
          ),
          body: switch ((viewModel.isLoading, viewModel.error, details)) {
            (true, _, null) => const Center(child: CircularProgressIndicator()),
            (_, final Exception error, null) => _ErrorState(
                message: error.toString(),
                onRetry: viewModel.load,
              ),
            (_, _, null) => const Center(
                child: Text('Não encontramos informações sobre este filme.'),
              ),
            (_, _, _) => _DetailsContent(
                viewModel: viewModel,
                trailerPlayerBuilder: widget.trailerPlayerBuilder,
              ),
          },
        );
      },
    );
  }
}

/// Conteúdo da tela quando os detalhes já foram carregados.
class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.viewModel,
    required this.trailerPlayerBuilder,
  });

  final MovieDetailsViewModel viewModel;
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = viewModel.details!;
    final year = formatReleaseYear(details.releaseDate);
    final runtime = formatRuntime(details.runtime);
    final rating = formatRating(details.voteAverage);
    final genres = details.genres ?? const <Genre>[];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _TrailerSection(
          youtubeKey: viewModel.trailerYoutubeKey,
          backdropPath: details.backdropPath,
          trailerPlayerBuilder: trailerPlayerBuilder,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title ?? details.originalTitle ?? 'Sem título',
                style: theme.textTheme.headlineSmall,
              ),
              if (details.tagline?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  details.tagline!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _MetadataRow(year: year, runtime: runtime, rating: rating),
              if (genres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final genre in genres)
                      Chip(label: Text(genre.name ?? '—')),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text('Sinopse', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                details.overview?.isNotEmpty == true
                    ? details.overview!
                    : 'Sinopse não disponível.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Área do trailer no topo da tela.
///
/// Quando o filme não tem trailer publicado, cai para a imagem de fundo do
/// filme com um aviso — a tela continua útil.
class _TrailerSection extends StatelessWidget {
  const _TrailerSection({
    required this.youtubeKey,
    required this.backdropPath,
    required this.trailerPlayerBuilder,
  });

  final String? youtubeKey;
  final String? backdropPath;
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  Widget build(BuildContext context) {
    final key = youtubeKey;
    if (key != null) {
      return KeyedSubtree(
        key: MovieDetailsPage.trailerKey,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: trailerPlayerBuilder(context, key),
        ),
      );
    }

    final backdropUrl = TmdbImages.backdrop(backdropPath);
    return Container(
      key: MovieDetailsPage.emptyTrailerKey,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (backdropUrl != null)
              Image.network(
                backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_outlined),
                  SizedBox(height: 8),
                  Text('Trailer não disponível'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha com nota, ano e duração do filme.
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({this.year, this.runtime, this.rating});

  final String? year;
  final String? runtime;
  final String? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (rating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(rating!, style: theme.textTheme.labelLarge),
            ],
          ),
        if (year != null) Text(year!, style: theme.textTheme.labelLarge),
        if (runtime != null) Text(runtime!, style: theme.textTheme.labelLarge),
      ],
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
            FilledButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
