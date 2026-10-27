import 'package:flutter/material.dart';

import '../../data/api_models/movie.dart';
import '../../l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(l10n.homeTitle)),
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
              onRetry: () => viewModel.load(forceRefresh: true),
            );
          }

          if (viewModel.isEmpty) {
            return Column(
              children: [
                _buildSearchField(l10n),
                Expanded(child: Center(child: Text(l10n.homeEmpty))),
              ],
            );
          }

          return Column(
            children: [
              _buildSearchField(l10n),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => viewModel.load(forceRefresh: true),
                  child: ListView.builder(
                    // Padding explícito desliga o recuo automático do sistema:
                    // sem somá-lo, o fim da lista fica sob a barra de navegação.
                    padding: const EdgeInsets.symmetric(vertical: 8) +
                        MediaQuery.paddingOf(context),
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
          labelText: l10n.searchLabel,
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
