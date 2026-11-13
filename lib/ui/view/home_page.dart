import 'package:flutter/material.dart';

import '../../data/api_models/movie.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/formatters.dart';
import '../../utils/tmdb_images.dart';
import '../view_model/favorites_view_model.dart';
import '../view_model/home_view_model.dart';
import '../view_model/movie_details_view_model.dart';
import '../view_model/movie_rating_view_model.dart';
import 'app_shell.dart';
import 'movie_details_page.dart';
import 'widgets/movie_ai_logo.dart';
import 'widgets/poster_card.dart';
import 'widgets/trailer_player.dart';

/// Cria a view model da tela de detalhes de um filme.
///
/// A home não conhece repositórios: ela apenas pede a view model já montada
/// para quem a construiu (o `main.dart`, ou o teste).
typedef MovieDetailsViewModelFactory =
    MovieDetailsViewModel Function(int movieId);

/// Cria a view model da avaliação de um filme, mostrada na tela de detalhes.
typedef MovieRatingViewModelFactory =
    MovieRatingViewModel Function(int movieId);

/// Tela inicial: o filme em destaque, os gêneros, o convite ao MovieAI e a
/// grade de populares (ou dos resultados da pesquisa), levando aos detalhes.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.viewModel,
    required this.detailsViewModelFactory,
    required this.ratingViewModelFactory,
    required this.favoritesViewModel,
    this.trailerPlayerBuilder = defaultTrailerPlayerBuilder,
  });

  /// Estado e comandos da tela.
  final HomeViewModel viewModel;

  /// Lista de favoritos, repassada para o coração da tela de detalhes.
  final FavoritesViewModel favoritesViewModel;

  /// Fábrica da view model usada ao abrir a tela de detalhes.
  final MovieDetailsViewModelFactory detailsViewModelFactory;

  /// Fábrica da view model da avaliação, também usada ao abrir os detalhes.
  final MovieRatingViewModelFactory ratingViewModelFactory;

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
    // Para a fileira de gêneros. Sem eles, a fileira só não aparece.
    widget.viewModel.loadGenres();
  }

  /// Abre a tela de detalhes do [movie] tocado.
  ///
  /// Roteamento simples como este é responsabilidade da view, segundo a
  /// arquitetura em camadas: a view model continua sem depender do Navigator.
  void _openDetails(Movie movie) {
    Navigator.of(context).push(
      MovieDetailsPage.route(
        viewModel: widget.detailsViewModelFactory(movie.id),
        ratingViewModel: widget.ratingViewModelFactory(movie.id),
        favoritesViewModel: widget.favoritesViewModel,
        fallbackTitle: movie.title,
        trailerPlayerBuilder: widget.trailerPlayerBuilder,
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
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (viewModel.genresError != null) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Text(AppLocalizations.of(context).genresLoadError),
                ),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context).advancedFilter,
                      style: const TextStyle(
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
                          value: viewModel.selectedGenreIds.contains(genre.id),
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
                          _searchController.clear();
                          await viewModel.applyGenreFilter();

                          if (!context.mounted) return;

                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).applyFilters),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const Center(child: MovieAiLogo()),
        title: const Text('MovieAI'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;

          if (viewModel.isLoading && viewModel.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // O detalhe técnico do erro vai para o log (veja a view model); o
          // usuário vê uma mensagem traduzida.
          if (viewModel.error != null) {
            return _ErrorState(
              message: l10n.homeLoadError,
              onRetry: viewModel.refresh,
            );
          }

          final movies = viewModel.movies;
          // O destaque é o primeiro dos populares; com pesquisa ou gênero, a
          // grade mostra só os resultados.
          final featured = viewModel.hasFilters || movies.isEmpty
              ? null
              : movies.first;
          final grid = featured == null ? movies : movies.skip(1).toList();
          final shell = AppShell.maybeOf(context);

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: CustomScrollView(
              // Puxar para atualizar funciona mesmo com pouco conteúdo.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchField(l10n)),
                if (featured != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FeaturedMovie(
                        key: ValueKey(featured.id),
                        movie: featured,
                        favoritesViewModel: widget.favoritesViewModel,
                        onOpen: () => _openDetails(featured),
                      ),
                    ),
                  ),
                if (viewModel.genres.isNotEmpty)
                  SliverToBoxAdapter(child: _buildGenreChips(l10n)),
                if (featured != null && shell != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _AssistantCard(
                        onOpen: () => shell.selectTab(AppShell.assistantTab),
                      ),
                    ),
                  ),
                if (viewModel.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l10n.homeEmpty)),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        viewModel.hasFilters
                            ? l10n.homeResults
                            : l10n.homeTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    // O recuo do sistema entra aqui: sem ele, o fim da grade
                    // fica sob a barra de navegação.
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: _PosterGrid(
                      movies: grid,
                      favoritesViewModel: widget.favoritesViewModel,
                      onOpen: _openDetails,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Campo de pesquisa com os botões de pesquisar e de filtro avançado.
  ///
  /// Aparece tanto com a lista cheia quanto vazia: o usuário precisa poder
  /// pesquisar de novo depois de uma busca sem resultado.
  Widget _buildSearchField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.viewModel.hasFilters)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.clearFilters,
                  onPressed: _clearFilters,
                ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.searchTooltip,
                onPressed: _search,
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: l10n.advancedFilter,
                onPressed: _openAdvancedFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fileira de gêneros: tocar num gênero já filtra, e "Todos" tira o filtro.
  Widget _buildGenreChips(AppLocalizations l10n) {
    final viewModel = widget.viewModel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        spacing: 8,
        children: [
          ChoiceChip(
            showCheckmark: false,
            label: Text(l10n.genreAll),
            selected: !viewModel.hasFilters,
            onSelected: (_) => _clearFilters(),
          ),
          for (final genre in viewModel.genres)
            ChoiceChip(
              showCheckmark: false,
              label: Text(genre.name),
              selected: viewModel.selectedGenreIds.contains(genre.id),
              onSelected: (_) {
                _searchController.clear();
                viewModel.quickToggleGenre(genre.id);
              },
            ),
        ],
      ),
    );
  }

  void _search() {
    widget.viewModel.search(_searchController.text);
  }

  void _clearFilters() {
    _searchController.clear();
    widget.viewModel.clearFilters();
  }
}

/// Filme em destaque no topo da home: a imagem de fundo ocupa o cartão, com
/// selo, nota, título, sinopse curta e os botões por cima.
class _FeaturedMovie extends StatelessWidget {
  const _FeaturedMovie({
    super.key,
    required this.movie,
    required this.favoritesViewModel,
    required this.onOpen,
  });

  final Movie movie;
  final FavoritesViewModel favoritesViewModel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final imageUrl =
        TmdbImages.backdrop(movie.backdropPath) ??
        TmdbImages.poster(movie.posterPath);
    final rating = formatRating(
      movie.voteAverage,
      Localizations.localeOf(context).toString(),
    );

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          height: 380,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              // Escurece a parte de baixo para o texto ler sobre a imagem.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.2, 1],
                    colors: [
                      scheme.surface.withValues(alpha: 0),
                      scheme.surface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Pill(
                          color: scheme.primary,
                          child: Text(
                            l10n.featuredBadge,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                        if (rating != null)
                          _Pill(
                            color: Colors.black.withValues(alpha: 0.6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.title ?? movie.originalTitle ?? l10n.untitled,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (movie.overview?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        movie.overview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onOpen,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(l10n.featuredDetails),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ListenableBuilder(
                          listenable: favoritesViewModel,
                          builder: (context, _) {
                            final isFavorite = favoritesViewModel.isFavorite(
                              movie.id,
                            );
                            return IconButton.filledTonal(
                              isSelected: isFavorite,
                              icon: const Icon(Icons.favorite_border),
                              selectedIcon: const Icon(Icons.favorite),
                              tooltip: isFavorite
                                  ? l10n.favoriteRemove
                                  : l10n.favoriteAdd,
                              onPressed: () => favoritesViewModel.toggle(movie),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta arredondada do destaque.
class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: child,
  );
}

/// Cartão que convida a pedir sugestões ao MovieAI e abre a aba dele.
class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHigh,
            scheme.secondaryContainer.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: scheme.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.assistantCardTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.assistantCardBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.tertiary,
              foregroundColor: scheme.onTertiary,
            ),
            onPressed: onOpen,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.assistantCardAction),
          ),
        ],
      ),
    );
  }
}

/// Grade de pôsteres em duas colunas.
///
/// Feita de linhas, e não de um `SliverGrid`: cada linha cresce com o texto,
/// então a fonte grande do sistema não corta os títulos.
class _PosterGrid extends StatelessWidget {
  const _PosterGrid({
    required this.movies,
    required this.favoritesViewModel,
    required this.onOpen,
  });

  final List<Movie> movies;
  final FavoritesViewModel favoritesViewModel;
  final ValueChanged<Movie> onOpen;

  static const columns = 2;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: (movies.length / columns).ceil(),
      itemBuilder: (context, row) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            for (var column = 0; column < columns; column++)
              Expanded(
                child: switch (row * columns + column) {
                  final index when index < movies.length => PosterCard(
                    key: ValueKey(movies[index].id),
                    movie: movies[index],
                    favoritesViewModel: favoritesViewModel,
                    onTap: () => onOpen(movies[index]),
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
          ],
        ),
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
