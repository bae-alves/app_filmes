// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get watchProvidersSubscription => 'Assinatura';

  @override
  String get watchProvidersFree => 'Grátis';

  @override
  String get watchProvidersRent => 'Alugar';

  @override
  String get watchProvidersBuy => 'Comprar';

  @override
  String get watchProvidersUnavailable =>
      'Indisponível em streaming na sua região';

  @override
  String get watchProvidersAttribution => 'Fonte: JustWatch';
}
