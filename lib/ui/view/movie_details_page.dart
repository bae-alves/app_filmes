import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/api_models/genre.dart';
import '../../data/api_models/movie.dart';
import '../../data/api_models/movie_details.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/tmdb_images.dart';
import '../view_model/favorites_view_model.dart';
import '../view_model/movie_details_view_model.dart';
import '../view_model/movie_rating_view_model.dart';
import 'widgets/rating_section.dart';
import 'widgets/trailer_player.dart';
import 'widgets/watch_providers_section.dart';

/// Tela de detalhes: mostra o trailer, as informações completas do filme e
/// onde ele pode ser assistido.
///
/// É alcançada ao tocar em um cartão da tela inicial ou da tela de favoritos.
class MovieDetailsPage extends StatefulWidget {
  const MovieDetailsPage({
    super.key,
    required this.viewModel,
    required this.ratingViewModel,
    required this.favoritesViewModel,
    this.fallbackTitle,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Identificador da rota, útil em testes e em navegação nomeada.
  static const routeName = '/movie-details';

  /// Chave do botão de coração, que liga e desliga o favorito.
  static const favoriteButtonKey = Key('movie-details-favorite');

  /// Rota até a tela de detalhes, usada por todas as telas que a abrem.
  static Route<void> route({
    required MovieDetailsViewModel viewModel,
    required MovieRatingViewModel ratingViewModel,
    required FavoritesViewModel favoritesViewModel,
    String? fallbackTitle,
    TrailerPlayerBuilder trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => MovieDetailsPage(
        viewModel: viewModel,
        ratingViewModel: ratingViewModel,
        favoritesViewModel: favoritesViewModel,
        fallbackTitle: fallbackTitle,
        trailerPlayerBuilder: trailerPlayerBuilder,
      ),
    );
  }

  /// Chave do bloco que hospeda o player do trailer.
  static const trailerKey = Key('movie-details-trailer');

  /// Chave do bloco exibido quando o filme não tem trailer publicado.
  static const emptyTrailerKey = Key('movie-details-trailer-empty');

  /// Estado e comandos da tela.
  final MovieDetailsViewModel viewModel;

  /// Nota e humor que o usuário deu ao filme.
  final MovieRatingViewModel ratingViewModel;

  /// Lista de favoritos, compartilhada com o resto do app.
  final FavoritesViewModel favoritesViewModel;

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
    widget.ratingViewModel.load();
  }

  @override
  void dispose() {
    // As duas são da tela, criadas a cada abertura; a de favoritos é do app.
    widget.viewModel.dispose();
    widget.ratingViewModel.dispose();
    super.dispose();
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
            actions: [
              if (viewModel.movieSummary case final movie?)
                _FavoriteButton(
                  movie: movie,
                  favoritesViewModel: widget.favoritesViewModel,
                ),
            ],
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
              ratingViewModel: widget.ratingViewModel,
              favoritesViewModel: widget.favoritesViewModel,
              trailerPlayerBuilder: widget.trailerPlayerBuilder,
            ),
          },
        );
      },
    );
  }
}

/// Coração da AppBar: favorita ou desfavorita o filme.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
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
          key: MovieDetailsPage.favoriteButtonKey,
          isSelected: isFavorite,
          icon: const Icon(Icons.favorite_border),
          selectedIcon: const Icon(Icons.favorite),
          tooltip: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
          onPressed: () => favoritesViewModel.toggle(movie),
        );
      },
    );
  }
}

/// Conteúdo da tela quando os detalhes já foram carregados.
///
/// Usa uma `Column` rolável, e não uma `ListView`, para que todas as seções
/// existam desde o início: os atalhos "Avaliar" e "Assistir" rolam até elas.
class _DetailsContent extends StatefulWidget {
  const _DetailsContent({
    required this.viewModel,
    required this.ratingViewModel,
    required this.favoritesViewModel,
    required this.trailerPlayerBuilder,
  });

  final MovieDetailsViewModel viewModel;
  final MovieRatingViewModel ratingViewModel;
  final FavoritesViewModel favoritesViewModel;
  final TrailerPlayerBuilder trailerPlayerBuilder;

  @override
  State<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends State<_DetailsContent> {
  final _ratingKey = GlobalKey();
  final _watchKey = GlobalKey();

  void _scrollTo(GlobalKey section) => Scrollable.ensureVisible(
    section.currentContext!,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final viewModel = widget.viewModel;
    final details = viewModel.details!;
    final genres = details.genres ?? const <Genre>[];
    final cast = viewModel.cast;
    final crew = [
      (l10n.crewDirector, viewModel.directorNames),
      (l10n.crewWriter, viewModel.writerNames),
      (l10n.crewMusic, viewModel.composerNames),
    ].where((role) => role.$2.isNotEmpty).toList();
    // A fileira mostra só o elenco principal; o resto fica em "Ver todos".
    const castPreview = 10;

    return SingleChildScrollView(
      // Padding explícito desliga o recuo automático do sistema: sem somá-lo, o
      // fim da tela fica sob a barra de navegação.
      padding:
          const EdgeInsets.only(bottom: 24) + MediaQuery.paddingOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TrailerSection(
            youtubeKey: viewModel.trailerYoutubeKey,
            backdropPath: details.backdropPath,
            trailerPlayerBuilder: widget.trailerPlayerBuilder,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (genres.isNotEmpty) ...[
                  _GenreTags(genres: genres),
                  const SizedBox(height: 12),
                ],
                Text(
                  details.title ?? details.originalTitle ?? l10n.untitled,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                if (details.tagline?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    details.tagline!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _MetadataRow(
                  year: formatReleaseYear(details.releaseDate),
                  runtime: formatRuntime(details.runtime, l10n),
                  rating: formatRating(details.voteAverage, locale),
                  votes: formatVoteCount(details.voteCount, locale),
                  certification: details.certificationFor(
                    viewModel.watchRegion,
                  ),
                ),
                const SizedBox(height: 20),
                _ActionRow(
                  movie: viewModel.movieSummary!,
                  favoritesViewModel: widget.favoritesViewModel,
                  ratingViewModel: widget.ratingViewModel,
                  onRate: () => _scrollTo(_ratingKey),
                  onWatch: () => _scrollTo(_watchKey),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: l10n.synopsisTitle,
                  child: _ExpandableText(
                    details.overview?.isNotEmpty == true
                        ? details.overview!
                        : l10n.synopsisUnavailable,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  key: _ratingKey,
                  child: RatingSection(viewModel: widget.ratingViewModel),
                ),
                if (cast.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.castTitle,
                          style: _SectionCard.titleStyle(theme),
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
                  const SizedBox(height: 12),
                  _CastList(cast: cast.take(castPreview).toList()),
                ],
                if (crew.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: l10n.crewTitle,
                    child: _CrewGrid(crew: crew),
                  ),
                ],
                const SizedBox(height: 16),
                _SectionCard(
                  key: _watchKey,
                  title: l10n.watchProvidersTitle,
                  child: viewModel.watchProvidersFailed
                      ? Text(
                          l10n.watchProvidersLoadError,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        )
                      : WatchProvidersSection(
                          region: viewModel.watchProviders,
                          onOpenLink: (link) => launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
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

/// Gêneros do filme em etiquetas: o primeiro em âmbar, o segundo em lilás e
/// os demais em cinza, como no design.
class _GenreTags extends StatelessWidget {
  const _GenreTags({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accents = [scheme.primary, scheme.secondary];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (index, genre) in genres.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: index < accents.length
                  ? accents[index].withValues(alpha: 0.16)
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              genre.name ?? '—',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: index < accents.length
                    ? accents[index]
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Linha com ano, classificação indicativa, duração e nota do filme,
/// separados por pontos.
class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    this.year,
    this.runtime,
    this.rating,
    this.votes,
    this.certification,
  });

  final String? year;
  final String? runtime;
  final String? rating;
  final String? votes;
  final String? certification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strong = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final certificationLabel = certification == null
        ? null
        : AppLocalizations.of(context).certificationLabel(certification!);
    final items = <Widget>[
      if (year != null) Text(year!, style: strong),
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
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(certification!, style: strong),
            ),
          ),
        ),
      if (runtime != null) Text(runtime!, style: theme.textTheme.labelLarge),
      if (rating != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 4),
              Text(rating!, style: strong?.copyWith(color: scheme.primary)),
              if (votes != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($votes)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
    ];
    final dot = Text('•', style: TextStyle(color: scheme.outline));
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) dot,
          item,
        ],
      ],
    );
  }
}

/// Atalhos abaixo do título: favoritar, ir até a avaliação e ir até onde
/// assistir.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.movie,
    required this.favoritesViewModel,
    required this.ratingViewModel,
    required this.onRate,
    required this.onWatch,
  });

  final Movie movie;
  final FavoritesViewModel favoritesViewModel;
  final MovieRatingViewModel ratingViewModel;
  final VoidCallback onRate;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([favoritesViewModel, ratingViewModel]),
      builder: (context, _) {
        final isFavorite = favoritesViewModel.isFavorite(movie.id);
        final isRated =
            ratingViewModel.stars != null || ratingViewModel.mood != null;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _ActionTile(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              label: isFavorite ? l10n.actionFavorited : l10n.actionFavorite,
              selected: isFavorite,
              onTap: () => favoritesViewModel.toggle(movie),
            ),
            _ActionTile(
              icon: isRated ? Icons.star_rounded : Icons.star_border_rounded,
              label: isRated ? l10n.actionRated : l10n.actionRate,
              selected: isRated,
              onTap: onRate,
            ),
            _ActionTile(
              icon: Icons.play_circle_outline,
              label: l10n.actionWatch,
              onTap: onWatch,
            ),
          ],
        );
      },
    );
  }
}

/// Um atalho da [_ActionRow]: ícone em âmbar sobre um rótulo curto.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão de uma seção da tela, com título opcional.
class _SectionCard extends StatelessWidget {
  const _SectionCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  /// Estilo dos títulos de seção, também usado pelo "Elenco", que não tem
  /// cartão.
  static TextStyle? titleStyle(ThemeData theme) =>
      theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle(theme)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

/// Texto cortado em [maxLines] linhas, com "ler mais" quando não cabe.
class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);

  final String text;

  static const maxLines = 4;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _ExpandableText.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : _ExpandableText.maxLines,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows)
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? l10n.readLess : l10n.readMore),
              ),
          ],
        );
      },
    );
  }
}

/// Direção, roteiro e trilha sonora, em duas colunas.
class _CrewGrid extends StatelessWidget {
  const _CrewGrid({required this.crew});

  /// Pares (função, nomes), só com as funções que têm alguém.
  final List<(String, List<String>)> crew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: gap,
        runSpacing: 12,
        children: [
          for (final (role, names) in crew)
            SizedBox(
              width: (constraints.maxWidth - gap) / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    names.join(', '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
