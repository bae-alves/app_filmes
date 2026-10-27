import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';

import 'data/repositories/movies_repository.dart';
import 'data/repositories/movies_repository_remote.dart';
import 'data/services/tmdb_dio.dart';
import 'data/services/tmdb_rest_client.dart';
import 'ui/view/home_page.dart';
import 'ui/view_model/home_view_model.dart';
import 'ui/view_model/movie_details_view_model.dart';
import 'utils/env.dart';
import 'utils/user_locale.dart';

Future<void> main() async {
  // `ensureInitialized` é necessário porque carregamos o .env (um asset) e o
  // armazenamento local antes de `runApp`.
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  final preferences = await SharedPreferences.getInstance();

  runApp(AppFilmes(preferences: preferences));
}

/// Raiz da aplicação e único ponto de composição das dependências.
///
/// É aqui que as camadas são costuradas — service → repository → view model →
/// view. Nenhuma camada instancia a camada de baixo por conta própria, o que
/// mantém todas elas substituíveis nos testes.
class AppFilmes extends StatefulWidget {
  const AppFilmes({super.key, required this.preferences});

  /// Armazenamento local, usado pelo cache de detalhes do repositório.
  final SharedPreferences preferences;

  @override
  State<AppFilmes> createState() => _AppFilmesState();
}

class _AppFilmesState extends State<AppFilmes> {
  late final MoviesRepository _moviesRepository;
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();

    final dio = createTmdbDio(readAccessToken: Env.tmdbReadToken);
    _moviesRepository = MoviesRepositoryRemote(
      restClient: TmdbRestClient(dio),
      // Mesmo idioma que o MaterialApp vai escolher para a interface.
      language: currentTmdbLanguage(),
      preferences: widget.preferences,
    );
    _homeViewModel = HomeViewModel(moviesRepository: _moviesRepository);
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Filmes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      // Idiomas suportados (EN e PT) e os textos traduzidos de lib/l10n. O
      // Flutter escolhe o idioma pela localidade do dispositivo, caindo para o
      // primeiro da lista quando ela não é suportada.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(
        viewModel: _homeViewModel,
        detailsViewModelFactory: (movieId) => MovieDetailsViewModel(
          moviesRepository: _moviesRepository,
          movieId: movieId,
          // Lida a cada abertura: se o usuário trocar a região do aparelho,
          // a próxima tela de detalhes já reflete a mudança.
          watchRegion: currentWatchRegion(),
        ),
      ),
    );
  }
}
