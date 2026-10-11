// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
