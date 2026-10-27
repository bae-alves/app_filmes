import 'package:flutter/material.dart';

import '../../data/api_models/genre.dart';
import '../../data/api_models/movie_details.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/tmdb_images.dart';
import '../view_model/movie_details_view_model.dart';
import 'widgets/trailer_player.dart';
import 'widgets/watch_providers_section.dart';

/// Tela de detalhes: mostra o trailer, as informações completas do filme e
/// onde ele pode ser assistido.
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
            title: Text(
              details?.title ??
                  widget.fallbackTitle ??
                  AppLocalizations.of(context).detailsFallbackTitle,
            ),
          ),
          body: switch ((viewModel.isLoading, viewModel.error, details)) {
            (true, _, null) => const Center(child: CircularProgressIndicator()),
            // O detalhe técnico do erro vai para o log (veja a view model);
            // o usuário vê uma mensagem traduzida.
            (_, Exception(), null) => _ErrorState(
                message: AppLocalizations.of(context).detailsLoadError,
                onRetry: viewModel.load,
              ),
            (_, _, null) => Center(
                child: Text(AppLocalizations.of(context).detailsNotFound),
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final details = viewModel.details!;
    final year = formatReleaseYear(details.releaseDate);
    final runtime = formatRuntime(details.runtime, l10n);
    final rating = formatRating(details.voteAverage, locale);
    final genres = details.genres ?? const <Genre>[];
    final directors = [
      for (final director in details.directors)
        if (director.name?.isNotEmpty == true) director.name!,
    ];
    final cast = [...?details.credits?.cast]
      ..sort((a, b) => (a.order ?? 999).compareTo(b.order ?? 999));
    // A fileira mostra só o elenco principal; o resto fica em "Ver todos".
    const castPreview = 10;

    return ListView(
      // Padding explícito desliga o recuo automático do sistema: sem somá-lo, o
      // fim da tela fica sob a barra de navegação.
      padding: const EdgeInsets.only(bottom: 24) + MediaQuery.paddingOf(context),
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
                details.title ?? details.originalTitle ?? l10n.untitled,
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
              if (directors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.directedBy(directors.join(', ')),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              _MetadataRow(
                year: year,
                runtime: runtime,
                rating: rating,
                certification: details.certificationFor(viewModel.watchRegion),
              ),
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
              Text(l10n.synopsisTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                details.overview?.isNotEmpty == true
                    ? details.overview!
                    : l10n.synopsisUnavailable,
                style: theme.textTheme.bodyMedium,
              ),
              if (cast.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.castTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (cast.length > castPreview)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _FullCastPage(cast: cast),
                          ),
                        ),
                        child: Text(l10n.castSeeAll),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _CastList(cast: cast.take(castPreview).toList()),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.watchProvidersTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (viewModel.watchProvidersFailed)
                Text(
                  l10n.watchProvidersLoadError,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                )
              else
                WatchProvidersSection(region: viewModel.watchProviders),
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
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off_outlined),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).trailerUnavailable),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha com nota, ano, duração e classificação indicativa do filme.
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    this.year,
    this.runtime,
    this.rating,
    this.certification,
  });

  final String? year;
  final String? runtime;
  final String? rating;
  final String? certification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final certificationLabel = certification == null
        ? null
        : AppLocalizations.of(context).certificationLabel(certification!);
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
        if (certificationLabel != null)
          Tooltip(
            message: certificationLabel,
            excludeFromSemantics: true,
            child: Semantics(
              label: certificationLabel,
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(certification!, style: theme.textTheme.labelLarge),
              ),
            ),
          ),
      ],
    );
  }
}

/// Fileira horizontal com foto, nome e personagem do elenco principal.
///
/// A altura acompanha o texto, e não é fixa: com a fonte do sistema grande, uma
/// altura fixa cortaria os nomes.
class _CastList extends StatelessWidget {
  const _CastList({required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [for (final member in cast) _CastMemberTile(member: member)],
      ),
    );
  }
}

/// Foto, nome e personagem de uma pessoa do elenco.
class _CastMemberTile extends StatelessWidget {
  const _CastMemberTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          _CastAvatar(member: member, radius: 36),
          const SizedBox(height: 6),
          Text(
            member.name ?? '—',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
          ),
          if (member.character?.isNotEmpty == true)
            Text(
              member.character!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }
}

/// Foto de uma pessoa do elenco, com um ícone no lugar quando não há foto.
class _CastAvatar extends StatelessWidget {
  const _CastAvatar({required this.member, required this.radius});

  final CastMember member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = TmdbImages.profile(member.profilePath);
    return CircleAvatar(
      radius: radius,
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      // Foto que não carrega fica no ícone, sem erro no log.
      onForegroundImageError: photoUrl != null ? (error, stackTrace) {} : null,
      child: const Icon(Icons.person_outline),
    );
  }
}

/// Elenco completo do filme, aberto pelo botão "Ver todos" da tela de detalhes.
class _FullCastPage extends StatelessWidget {
  const _FullCastPage({required this.cast});

  /// Elenco já ordenado por destaque.
  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).castTitle)),
      body: ListView.builder(
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final member = cast[index];
          return ListTile(
            leading: _CastAvatar(member: member, radius: 20),
            title: Text(member.name ?? '—'),
            subtitle: member.character?.isNotEmpty == true
                ? Text(member.character!)
                : null,
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
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
