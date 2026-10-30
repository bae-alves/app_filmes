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

  /// Botão das telas de erro que repete o carregamento.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// Substitui o título de um filme que o TMDB devolve sem nome.
  ///
  /// In pt, this message translates to:
  /// **'Sem título'**
  String get untitled;

  /// Substitui a sinopse de um filme que o TMDB devolve sem texto (cartão da home e tela de detalhes).
  ///
  /// In pt, this message translates to:
  /// **'Sinopse não disponível.'**
  String get synopsisUnavailable;

  /// Duração do filme com horas e minutos (ex.: 2h 46min). Mantenha curto: aparece numa linha de metadados.
  ///
  /// In pt, this message translates to:
  /// **'{hours}h {minutes}min'**
  String runtimeHoursMinutes(int hours, int minutes);

  /// Duração do filme exata em horas (ex.: 2h).
  ///
  /// In pt, this message translates to:
  /// **'{hours}h'**
  String runtimeHours(int hours);

  /// Duração de um filme com menos de uma hora (ex.: 45min).
  ///
  /// In pt, this message translates to:
  /// **'{minutes}min'**
  String runtimeMinutes(int minutes);

  /// Título da tela inicial, que lista os filmes populares do momento.
  ///
  /// In pt, this message translates to:
  /// **'Filmes populares'**
  String get homeTitle;

  /// Aviso da tela inicial quando a lista (populares, pesquisa ou filtro) volta vazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum filme encontrado no momento.'**
  String get homeEmpty;

  /// Erro da tela inicial quando a lista de filmes não carrega. O detalhe técnico vai só para o log.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os filmes.'**
  String get homeLoadError;

  /// Rótulo do campo de pesquisa da tela inicial.
  ///
  /// In pt, this message translates to:
  /// **'Nome do filme'**
  String get searchLabel;

  /// Texto de exemplo dentro do campo de pesquisa vazio.
  ///
  /// In pt, this message translates to:
  /// **'Digite o nome do filme'**
  String get searchHint;

  /// Dica e rótulo de acessibilidade do botão de lupa que dispara a pesquisa.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar'**
  String get searchTooltip;

  /// Botão da tela inicial e título da folha que filtra os filmes por gênero.
  ///
  /// In pt, this message translates to:
  /// **'Filtro avançado'**
  String get advancedFilter;

  /// Botão da folha de filtro avançado que aplica os gêneros marcados.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar filtros'**
  String get applyFilters;

  /// Dica e rótulo de acessibilidade do botão de X no campo de pesquisa, que apaga a pesquisa e os gêneros marcados.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get clearFilters;

  /// Erro da folha de filtro avançado quando a lista de gêneros não carrega.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os gêneros.'**
  String get genresLoadError;

  /// Título da barra superior da tela de detalhes enquanto o nome do filme não é conhecido.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get detailsFallbackTitle;

  /// Erro da tela de detalhes quando as informações do filme não carregam. O detalhe técnico vai só para o log.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar este filme.'**
  String get detailsLoadError;

  /// Aviso da tela de detalhes quando o carregamento termina sem erro, mas sem dados.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos informações sobre este filme.'**
  String get detailsNotFound;

  /// Título da seção da tela de detalhes com o resumo do filme.
  ///
  /// In pt, this message translates to:
  /// **'Sinopse'**
  String get synopsisTitle;

  /// Aviso no lugar do player quando o filme não tem trailer publicado.
  ///
  /// In pt, this message translates to:
  /// **'Trailer não disponível'**
  String get trailerUnavailable;

  /// Título da seção da tela de detalhes que lista os serviços de streaming do filme.
  ///
  /// In pt, this message translates to:
  /// **'Onde assistir'**
  String get watchProvidersTitle;

  /// Grupo de serviços em que o filme está incluído na assinatura (ex.: Netflix, Max).
  ///
  /// In pt, this message translates to:
  /// **'Assinatura'**
  String get watchProvidersSubscription;

  /// Grupo de serviços em que o filme é gratuito, com ou sem anúncios.
  ///
  /// In pt, this message translates to:
  /// **'Grátis'**
  String get watchProvidersFree;

  /// Grupo de serviços em que o filme pode ser alugado.
  ///
  /// In pt, this message translates to:
  /// **'Alugar'**
  String get watchProvidersRent;

  /// Grupo de serviços em que o filme pode ser comprado.
  ///
  /// In pt, this message translates to:
  /// **'Comprar'**
  String get watchProvidersBuy;

  /// Aviso exibido quando o filme não está em nenhum serviço de streaming na região do usuário.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível em streaming na sua região'**
  String get watchProvidersUnavailable;

  /// Botão que abre, fora do app, a página do TMDB com os links para cada serviço de streaming.
  ///
  /// In pt, this message translates to:
  /// **'Ver onde assistir'**
  String get watchProvidersSeeWhere;

  /// Crédito obrigatório pelos termos do TMDB: os dados de streaming vêm da JustWatch. Não traduza o nome JustWatch.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: JustWatch'**
  String get watchProvidersAttribution;

  /// Aviso na seção "Onde assistir" quando a consulta falha. Diferente de watchProvidersUnavailable: aqui não se sabe se o filme está em algum serviço.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar onde assistir'**
  String get watchProvidersLoadError;

  /// Título da seção da tela de detalhes com os atores principais.
  ///
  /// In pt, this message translates to:
  /// **'Elenco'**
  String get castTitle;

  /// Botão ao lado do título "Elenco" que abre a lista completa do elenco.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get castSeeAll;

  /// Linha da tela de detalhes com o(s) diretor(es) do filme, já separados por vírgula.
  ///
  /// In pt, this message translates to:
  /// **'Direção: {names}'**
  String directedBy(String names);

  /// Dica e rótulo de acessibilidade do selo com a classificação indicativa do país do usuário (ex.: 14, L, PG-13).
  ///
  /// In pt, this message translates to:
  /// **'Classificação indicativa: {certification}'**
  String certificationLabel(String certification);

  /// Título da tela com a lista de favoritos (watchlist) e dica do botão da tela inicial que a abre.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritesTitle;

  /// Mensagem da tela de favoritos quando a lista está vazia. Explica como adicionar um filme.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum filme nos favoritos ainda. Toque no coração na tela de um filme para salvá-lo aqui.'**
  String get favoritesEmpty;

  /// Mensagem da tela de favoritos quando a leitura da lista salva no aparelho falha.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os favoritos.'**
  String get favoritesLoadError;

  /// Dica do botão de coração (vazio) da tela de detalhes, que salva o filme nos favoritos.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos favoritos'**
  String get favoriteAdd;

  /// Dica do botão de coração (cheio) da tela de detalhes, que tira o filme dos favoritos.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get favoriteRemove;

  /// Aviso na parte de baixo da tela de favoritos depois de remover um filme, ao lado do botão "Desfazer".
  ///
  /// In pt, this message translates to:
  /// **'{title} saiu dos favoritos'**
  String favoriteRemoved(String title);

  /// Ação do aviso de filme removido: devolve o filme à lista, no mesmo lugar.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// Título da seção da tela de detalhes onde o usuário dá nota e reação de humor ao filme.
  ///
  /// In pt, this message translates to:
  /// **'Sua avaliação'**
  String get ratingTitle;

  /// Linha abaixo de "Sua avaliação". Explica que a avaliação é para filmes já assistidos.
  ///
  /// In pt, this message translates to:
  /// **'Já assistiu? Dê uma nota e conte como foi.'**
  String get ratingHint;

  /// Dica e rótulo de acessibilidade de cada estrela da avaliação (de 1 a 5).
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 estrela} other{{count} estrelas}}'**
  String ratingStars(int count);

  /// Reação de humor ao filme, ao lado do emoji 😍.
  ///
  /// In pt, this message translates to:
  /// **'Amei'**
  String get moodLoved;

  /// Reação de humor ao filme, ao lado do emoji 😂.
  ///
  /// In pt, this message translates to:
  /// **'Divertido'**
  String get moodFunny;

  /// Reação de humor ao filme, ao lado do emoji 😢. O filme comoveu o usuário.
  ///
  /// In pt, this message translates to:
  /// **'Emocionante'**
  String get moodMoved;

  /// Reação de humor ao filme, ao lado do emoji 😱. Suspense, medo.
  ///
  /// In pt, this message translates to:
  /// **'Tenso'**
  String get moodTense;

  /// Reação de humor ao filme, ao lado do emoji 😴.
  ///
  /// In pt, this message translates to:
  /// **'Entediante'**
  String get moodBored;
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
