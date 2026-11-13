import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @untitled.
  ///
  /// In pt, this message translates to:
  /// **'Sem título'**
  String get untitled;

  /// No description provided for @synopsisUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Sinopse não disponível.'**
  String get synopsisUnavailable;

  /// No description provided for @runtimeHoursMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{hours}h {minutes}min'**
  String runtimeHoursMinutes(Object hours, Object minutes);

  /// No description provided for @runtimeHours.
  ///
  /// In pt, this message translates to:
  /// **'{hours}h'**
  String runtimeHours(Object hours);

  /// No description provided for @runtimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes}min'**
  String runtimeMinutes(Object minutes);

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @homeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Filmes populares'**
  String get homeTitle;

  /// No description provided for @homeEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum filme encontrado no momento.'**
  String get homeEmpty;

  /// No description provided for @homeLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os filmes.'**
  String get homeLoadError;

  /// No description provided for @homeResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados'**
  String get homeResults;

  /// No description provided for @featuredBadge.
  ///
  /// In pt, this message translates to:
  /// **'#1 em alta'**
  String get featuredBadge;

  /// No description provided for @featuredDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get featuredDetails;

  /// No description provided for @genreAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get genreAll;

  /// No description provided for @assistantCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem ideia do que assistir?'**
  String get assistantCardTitle;

  /// No description provided for @assistantCardBody.
  ///
  /// In pt, this message translates to:
  /// **'Conte como você está e o MovieAI sugere filmes para o seu momento.'**
  String get assistantCardBody;

  /// No description provided for @assistantCardAction.
  ///
  /// In pt, this message translates to:
  /// **'Perguntar ao MovieAI'**
  String get assistantCardAction;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite o nome do filme'**
  String get searchHint;

  /// No description provided for @advancedFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtro avançado'**
  String get advancedFilter;

  /// No description provided for @applyFilters.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get clearFilters;

  /// No description provided for @genresLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os gêneros.'**
  String get genresLoadError;

  /// No description provided for @detailsFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get detailsFallbackTitle;

  /// No description provided for @detailsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar este filme.'**
  String get detailsLoadError;

  /// No description provided for @detailsNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos informações sobre este filme.'**
  String get detailsNotFound;

  /// No description provided for @synopsisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sinopse'**
  String get synopsisTitle;

  /// No description provided for @trailerUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Trailer não disponível'**
  String get trailerUnavailable;

  /// No description provided for @watchProvidersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Onde assistir'**
  String get watchProvidersTitle;

  /// No description provided for @watchProvidersSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura'**
  String get watchProvidersSubscription;

  /// No description provided for @watchProvidersFree.
  ///
  /// In pt, this message translates to:
  /// **'Grátis'**
  String get watchProvidersFree;

  /// No description provided for @watchProvidersRent.
  ///
  /// In pt, this message translates to:
  /// **'Alugar'**
  String get watchProvidersRent;

  /// No description provided for @watchProvidersBuy.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get watchProvidersBuy;

  /// No description provided for @watchProvidersUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível em streaming na sua região'**
  String get watchProvidersUnavailable;

  /// No description provided for @watchProvidersSeeWhere.
  ///
  /// In pt, this message translates to:
  /// **'Ver onde assistir'**
  String get watchProvidersSeeWhere;

  /// No description provided for @watchProvidersAttribution.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: JustWatch'**
  String get watchProvidersAttribution;

  /// No description provided for @watchProvidersLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar onde assistir'**
  String get watchProvidersLoadError;

  /// No description provided for @castTitle.
  ///
  /// In pt, this message translates to:
  /// **'Elenco'**
  String get castTitle;

  /// No description provided for @castSeeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get castSeeAll;

  /// No description provided for @crewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Direção e equipe'**
  String get crewTitle;

  /// No description provided for @crewDirector.
  ///
  /// In pt, this message translates to:
  /// **'Direção'**
  String get crewDirector;

  /// No description provided for @crewWriter.
  ///
  /// In pt, this message translates to:
  /// **'Roteiro'**
  String get crewWriter;

  /// No description provided for @crewMusic.
  ///
  /// In pt, this message translates to:
  /// **'Trilha sonora'**
  String get crewMusic;

  /// No description provided for @readMore.
  ///
  /// In pt, this message translates to:
  /// **'ler mais'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In pt, this message translates to:
  /// **'ler menos'**
  String get readLess;

  /// No description provided for @actionFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Favoritar'**
  String get actionFavorite;

  /// No description provided for @actionFavorited.
  ///
  /// In pt, this message translates to:
  /// **'Nos favoritos'**
  String get actionFavorited;

  /// No description provided for @actionRate.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar'**
  String get actionRate;

  /// No description provided for @actionRated.
  ///
  /// In pt, this message translates to:
  /// **'Avaliado'**
  String get actionRated;

  /// No description provided for @actionWatch.
  ///
  /// In pt, this message translates to:
  /// **'Assistir'**
  String get actionWatch;

  /// No description provided for @certificationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Classificação indicativa: {certification}'**
  String certificationLabel(Object certification);

  /// No description provided for @favoritesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum filme nos favoritos ainda. Toque no coração na tela de um filme para salvá-lo aqui.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os favoritos.'**
  String get favoritesLoadError;

  /// No description provided for @favoriteAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos favoritos'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get favoriteRemove;

  /// No description provided for @favoriteRemoved.
  ///
  /// In pt, this message translates to:
  /// **'{title} saiu dos favoritos'**
  String favoriteRemoved(Object title);

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @ratingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua avaliação'**
  String get ratingTitle;

  /// No description provided for @ratingHint.
  ///
  /// In pt, this message translates to:
  /// **'Já assistiu? Dê uma nota e conte como foi.'**
  String get ratingHint;

  /// No description provided for @ratingStars.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 estrela} other{{count} estrelas}}'**
  String ratingStars(num count);

  /// No description provided for @moodLoved.
  ///
  /// In pt, this message translates to:
  /// **'Amei'**
  String get moodLoved;

  /// No description provided for @moodFunny.
  ///
  /// In pt, this message translates to:
  /// **'Divertido'**
  String get moodFunny;

  /// No description provided for @moodMoved.
  ///
  /// In pt, this message translates to:
  /// **'Emocionante'**
  String get moodMoved;

  /// No description provided for @moodTense.
  ///
  /// In pt, this message translates to:
  /// **'Tenso'**
  String get moodTense;

  /// No description provided for @moodBored.
  ///
  /// In pt, this message translates to:
  /// **'Entediante'**
  String get moodBored;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual é o seu clima para hoje?'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Conte como você está se sentindo ou qual tipo de filme gostaria de assistir.'**
  String get chatEmptyBody;

  /// No description provided for @chatInputHint.
  ///
  /// In pt, this message translates to:
  /// **'Descreva seu humor...'**
  String get chatInputHint;

  /// No description provided for @chatSendTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Enviar mensagem'**
  String get chatSendTooltip;

  /// No description provided for @chatMovieSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Separei estes filmes para você:'**
  String get chatMovieSuggestions;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get nameLabel;

  /// No description provided for @loginSocialGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginSocialGoogle;

  /// No description provided for @loginSocialApple.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Apple'**
  String get loginSocialApple;

  /// No description provided for @orDivider.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get orDivider;

  /// No description provided for @noAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get noAccountPrompt;

  /// No description provided for @hasAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta?'**
  String get hasAccountPrompt;

  /// No description provided for @logoutAction.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logoutAction;

  /// No description provided for @saveProfile.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveProfile;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada com sucesso!'**
  String get accountCreatedSuccess;

  /// No description provided for @onboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Monte seu Perfil de Gosto'**
  String get onboardingTitle;

  /// No description provided for @onboardingStepLabel.
  ///
  /// In pt, this message translates to:
  /// **'Etapa {step} de {total}'**
  String onboardingStepLabel(Object step, Object total);

  /// No description provided for @onboardingGenresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quais são seus gêneros favoritos?'**
  String get onboardingGenresTitle;

  /// No description provided for @onboardingGenresSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecione os estilos de filme que você mais gosta de assistir.'**
  String get onboardingGenresSubtitle;

  /// No description provided for @onboardingActorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atores e Atrizes que você curte'**
  String get onboardingActorsTitle;

  /// No description provided for @onboardingActorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha os artistas que te fazem querer assistir um filme.'**
  String get onboardingActorsSubtitle;

  /// No description provided for @onboardingDirectorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diretores marcantes'**
  String get onboardingDirectorsTitle;

  /// No description provided for @onboardingDirectorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecione cineastas cujo estilo de direção você admira.'**
  String get onboardingDirectorsSubtitle;

  /// No description provided for @btnBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get btnBack;

  /// No description provided for @btnSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get btnSkip;

  /// No description provided for @btnNext.
  ///
  /// In pt, this message translates to:
  /// **'Avançar'**
  String get btnNext;

  /// No description provided for @btnFinish.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get btnFinish;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para salvar seus filmes e preferências'**
  String get profileLoginPrompt;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado com sucesso!'**
  String get profileUpdatedSuccess;

  /// No description provided for @btnCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get btnCancel;

  /// No description provided for @emailRequiredError.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu e-mail'**
  String get emailRequiredError;

  /// No description provided for @emailInvalidError.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get emailInvalidError;

  /// No description provided for @passwordRequiredError.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha'**
  String get passwordRequiredError;

  /// No description provided for @nameRequiredError.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu nome completo'**
  String get nameRequiredError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres'**
  String get passwordTooShortError;

  /// No description provided for @tastePreferencesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Preferências de gosto'**
  String get tastePreferencesTitle;

  /// No description provided for @tastePreferencesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar gêneros, atores e diretores favoritos'**
  String get tastePreferencesSubtitle;

  /// No description provided for @tastePreferencesUpdatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Preferências de gosto atualizadas! A IA já ajustou suas recomendações.'**
  String get tastePreferencesUpdatedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
