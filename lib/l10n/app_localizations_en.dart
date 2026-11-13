// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Try again';

  @override
  String get untitled => 'Untitled';

  @override
  String get synopsisUnavailable => 'Synopsis not available.';

  @override
  String runtimeHoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String runtimeHours(Object hours) {
    return '${hours}h';
  }

  @override
  String runtimeMinutes(Object minutes) {
    return '${minutes}m';
  }

  @override
  String get navHome => 'Home';

  @override
  String get homeTitle => 'Popular movies';

  @override
  String get homeEmpty => 'No movies found right now.';

  @override
  String get homeLoadError => 'Couldn\'t load the movies.';

  @override
  String get homeResults => 'Results';

  @override
  String get featuredBadge => '#1 trending';

  @override
  String get featuredDetails => 'See details';

  @override
  String get genreAll => 'All';

  @override
  String get assistantCardTitle => 'Not sure what to watch?';

  @override
  String get assistantCardBody =>
      'Tell MovieAI how you feel and get movies for the moment.';

  @override
  String get assistantCardAction => 'Ask MovieAI';

  @override
  String get searchHint => 'Type a movie title';

  @override
  String get advancedFilter => 'Advanced filter';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get genresLoadError => 'Couldn\'t load the genres.';

  @override
  String get detailsFallbackTitle => 'Details';

  @override
  String get detailsLoadError => 'Couldn\'t load this movie.';

  @override
  String get detailsNotFound =>
      'We couldn\'t find any information about this movie.';

  @override
  String get synopsisTitle => 'Synopsis';

  @override
  String get trailerUnavailable => 'Trailer not available';

  @override
  String get watchProvidersTitle => 'Where to watch';

  @override
  String get watchProvidersSubscription => 'Subscription';

  @override
  String get watchProvidersFree => 'Free';

  @override
  String get watchProvidersRent => 'Rent';

  @override
  String get watchProvidersBuy => 'Buy';

  @override
  String get watchProvidersUnavailable =>
      'Not available for streaming in your region';

  @override
  String get watchProvidersSeeWhere => 'See where to watch';

  @override
  String get watchProvidersAttribution => 'Source: JustWatch';

  @override
  String get watchProvidersLoadError => 'Couldn\'t load where to watch';

  @override
  String get castTitle => 'Cast';

  @override
  String get castSeeAll => 'See all';

  @override
  String get crewTitle => 'Director and crew';

  @override
  String get crewDirector => 'Director';

  @override
  String get crewWriter => 'Writing';

  @override
  String get crewMusic => 'Music';

  @override
  String get readMore => 'read more';

  @override
  String get readLess => 'read less';

  @override
  String get actionFavorite => 'Favorite';

  @override
  String get actionFavorited => 'Favorited';

  @override
  String get actionRate => 'Rate';

  @override
  String get actionRated => 'Rated';

  @override
  String get actionWatch => 'Watch';

  @override
  String certificationLabel(Object certification) {
    return 'Age rating: $certification';
  }

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty =>
      'No favorites yet. Tap the heart on a movie\'s page to save it here.';

  @override
  String get favoritesLoadError => 'Couldn\'t load your favorites.';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String favoriteRemoved(Object title) {
    return 'Removed $title from favorites';
  }

  @override
  String get undo => 'Undo';

  @override
  String get ratingTitle => 'Your rating';

  @override
  String get ratingHint => 'Seen it? Rate it and tell us how it felt.';

  @override
  String ratingStars(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get moodLoved => 'Loved it';

  @override
  String get moodFunny => 'Funny';

  @override
  String get moodMoved => 'Moving';

  @override
  String get moodTense => 'Tense';

  @override
  String get moodBored => 'Boring';

  @override
  String get chatEmptyTitle => 'What\'s your mood today?';

  @override
  String get chatEmptyBody =>
      'Tell us how you are feeling or what kind of movie you would like to watch.';

  @override
  String get chatInputHint => 'Describe your mood...';

  @override
  String get chatSendTooltip => 'Send message';

  @override
  String get chatMovieSuggestions => 'I picked these movies for you:';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Full name';

  @override
  String get loginSocialGoogle => 'Sign in with Google';

  @override
  String get loginSocialApple => 'Sign in with Apple';

  @override
  String get orDivider => 'or';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get hasAccountPrompt => 'Already have an account?';

  @override
  String get logoutAction => 'Sign out';

  @override
  String get saveProfile => 'Save changes';

  @override
  String get accountCreatedSuccess => 'Account created successfully!';

  @override
  String get onboardingTitle => 'Set Up Your Taste Profile';

  @override
  String onboardingStepLabel(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingGenresTitle => 'What are your favorite genres?';

  @override
  String get onboardingGenresSubtitle =>
      'Select movie genres you enjoy watching most.';

  @override
  String get onboardingActorsTitle => 'Actors & Actresses you like';

  @override
  String get onboardingActorsSubtitle =>
      'Choose stars that make you want to watch a movie.';

  @override
  String get onboardingDirectorsTitle => 'Impactful Directors';

  @override
  String get onboardingDirectorsSubtitle =>
      'Select directors whose filmmaking style you admire.';

  @override
  String get btnBack => 'Back';

  @override
  String get btnSkip => 'Skip';

  @override
  String get btnNext => 'Next';

  @override
  String get btnFinish => 'Finish';

  @override
  String get profileLoginPrompt =>
      'Sign in to save your movies and preferences';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get emailRequiredError => 'Enter your email';

  @override
  String get emailInvalidError => 'Invalid email';

  @override
  String get passwordRequiredError => 'Enter your password';

  @override
  String get nameRequiredError => 'Enter your full name';

  @override
  String get passwordTooShortError => 'Password must be at least 6 characters';

  @override
  String get tastePreferencesTitle => 'Taste Preferences';

  @override
  String get tastePreferencesSubtitle =>
      'Edit favorite genres, actors and directors';

  @override
  String get tastePreferencesUpdatedSuccess =>
      'Taste preferences updated! AI recommendations adjusted.';
}
