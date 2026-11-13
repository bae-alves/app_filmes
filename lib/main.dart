import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_local.dart';
import 'data/repositories/auth_repository_supabase.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/favorites_repository_local.dart';
import 'data/repositories/movies_repository.dart';
import 'data/repositories/movies_repository_remote.dart';
import 'data/repositories/onboarding_repository.dart';
import 'data/repositories/ratings_repository.dart';
import 'data/repositories/ratings_repository_local.dart';
import 'data/services/app_database.dart';
import 'data/services/gemini_service.dart';
import 'data/services/recommendation_context_service.dart';
import 'data/services/tmdb_dio.dart';
import 'data/services/tmdb_rest_client.dart';
import 'l10n/app_localizations.dart';
import 'ui/theme/app_theme.dart';
import 'ui/view/app_shell.dart';
import 'ui/view/chat_page.dart';
import 'ui/view/favorites_page.dart';
import 'ui/view/home_page.dart';
import 'ui/view/onboarding_page.dart';
import 'ui/view/profile_page.dart';
import 'ui/view_model/auth_view_model.dart';
import 'ui/view_model/chat_view_model.dart';
import 'ui/view_model/favorites_view_model.dart';
import 'ui/view_model/home_view_model.dart';
import 'ui/view_model/movie_details_view_model.dart';
import 'ui/view_model/movie_rating_view_model.dart';
import 'ui/view_model/onboarding_view_model.dart';
import 'utils/env.dart';
import 'utils/result.dart';
import 'utils/user_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['PlusJakartaSans'], license);
  });

  await Env.load();

  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl!,
      publishableKey: Env.supabaseAnonKey!,
    );
  }

  final preferences = await SharedPreferences.getInstance();
  final database = await AppDatabase.open();

  runApp(AppFilmes(preferences: preferences, database: database));
}

/// Raiz da aplicação e único ponto de composição das dependências.
class AppFilmes extends StatefulWidget {
  const AppFilmes({
    super.key,
    required this.preferences,
    required this.database,
  });

  final SharedPreferences preferences;
  final Database database;

  @override
  State<AppFilmes> createState() => _AppFilmesState();
}

class _AppFilmesState extends State<AppFilmes> {
  late final AuthRepository _authRepository;
  late final AuthViewModel _authViewModel;
  late final OnboardingRepository _onboardingRepository;
  late final MoviesRepository _moviesRepository;
  late final RatingsRepository _ratingsRepository;
  late final HomeViewModel _homeViewModel;
  late final GeminiService _geminiService;
  late final ChatViewModel _chatViewModel;
  late final FavoritesViewModel _favoritesViewModel;
  late final FavoritesRepository _favoritesRepository;
  late final RecommendationContextService _recommendationContextService;

  @override
  void initState() {
    super.initState();

    _authRepository = Env.isSupabaseConfigured
        ? AuthRepositorySupabase(client: Supabase.instance.client)
        : AuthRepositoryLocal(
            database: widget.database,
            preferences: widget.preferences,
          );

    _authViewModel = AuthViewModel(authRepository: _authRepository)
      ..loadSession();

    _onboardingRepository = OnboardingRepositoryLocal(
      database: widget.database,
    );

    final dio = createTmdbDio(readAccessToken: Env.tmdbReadToken);

    _moviesRepository = MoviesRepositoryRemote(
      restClient: TmdbRestClient(dio),
      language: currentTmdbLanguage(),
      preferences: widget.preferences,
    );

    _homeViewModel = HomeViewModel(moviesRepository: _moviesRepository);

    _geminiService = GeminiService(apiKey: () => Env.geminiApiKey);

    String? currentUserId() => _authViewModel.currentUser?.id;

    _favoritesRepository = FavoritesRepositoryLocal(
      database: widget.database,
      currentUserIdProvider: currentUserId,
    );

    _ratingsRepository = RatingsRepositoryLocal(
      database: widget.database,
      currentUserIdProvider: currentUserId,
    );

    _recommendationContextService = RecommendationContextService(
      favoritesRepository: _favoritesRepository,
      ratingsRepository: _ratingsRepository,
      moviesRepository: _moviesRepository,
      onboardingRepository: _onboardingRepository,
      currentUserIdProvider: currentUserId,
    );

    _favoritesViewModel = FavoritesViewModel(
      favoritesRepository: _favoritesRepository,
    )..load();

    _chatViewModel = ChatViewModel(
      geminiService: _geminiService,
      moviesRepository: _moviesRepository,
      recommendationContextService: _recommendationContextService,
    );
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _homeViewModel.dispose();
    _chatViewModel.dispose();
    _favoritesViewModel.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowOnboarding() async {
    final user = _authViewModel.currentUser;
    if (user == null) return;

    final res = await _onboardingRepository.getPreferences(user.id);
    if (!mounted) return;

    if (res case Ok(:final value)) {
      if (!value.isCompleted) {
        final vm = OnboardingViewModel(
          onboardingRepository: _onboardingRepository,
          userId: user.id,
        );

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (routeContext) => OnboardingPage(
              viewModel: vm,
              onCompleted: () {
                if (Navigator.of(routeContext).canPop()) {
                  Navigator.of(routeContext).pop();
                }
                _favoritesViewModel.load();
              },
            ),
          ),
        );
      }
    }
  }

  void _onUserSessionChanged() {
    _favoritesViewModel.load();
    _checkAndShowOnboarding();
  }

  MovieDetailsViewModel _detailsViewModel(int movieId) => MovieDetailsViewModel(
    moviesRepository: _moviesRepository,
    movieId: movieId,
    watchRegion: currentWatchRegion(),
  );

  MovieRatingViewModel _ratingViewModel(int movieId) => MovieRatingViewModel(
    ratingsRepository: _ratingsRepository,
    movieId: movieId,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieAI',
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppShell(
        home: HomePage(
          viewModel: _homeViewModel,
          favoritesViewModel: _favoritesViewModel,
          detailsViewModelFactory: _detailsViewModel,
          ratingViewModelFactory: _ratingViewModel,
        ),
        assistant: ChatPage(
          viewModel: _chatViewModel,
          favoritesViewModel: _favoritesViewModel,
          detailsViewModelFactory: _detailsViewModel,
          ratingViewModelFactory: _ratingViewModel,
        ),
        favorites: FavoritesPage(
          viewModel: _favoritesViewModel,
          detailsViewModelFactory: _detailsViewModel,
          ratingViewModelFactory: _ratingViewModel,
        ),
        profile: ProfilePage(
          authViewModel: _authViewModel,
          onboardingRepository: _onboardingRepository,
          onUserChanged: _onUserSessionChanged,
        ),
      ),
    );
  }
}
