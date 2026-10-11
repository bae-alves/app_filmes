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
  String runtimeHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String runtimeHours(int hours) {
    return '${hours}h';
  }

  @override
  String runtimeMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get homeTitle => 'Popular movies';

  @override
  String get homeEmpty => 'No movies found right now.';

  @override
  String get homeLoadError => 'Couldn\'t load the movies.';

  @override
  String get searchLabel => 'Movie title';

  @override
  String get searchHint => 'Type a movie title';

  @override
  String get searchTooltip => 'Search';

  @override
  String get advancedFilter => 'Advanced filter';

  @override
  String get applyFilters => 'Apply filters';

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
}
