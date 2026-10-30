// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get retry => 'Tentar novamente';

  @override
  String get untitled => 'Sem título';

  @override
  String get synopsisUnavailable => 'Sinopse não disponível.';

  @override
  String runtimeHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String runtimeHours(int hours) {
    return '${hours}h';
  }

  @override
  String runtimeMinutes(int minutes) {
    return '${minutes}min';
  }

  @override
  String get homeTitle => 'Filmes populares';

  @override
  String get homeEmpty => 'Nenhum filme encontrado no momento.';

  @override
  String get homeLoadError => 'Não foi possível carregar os filmes.';

  @override
  String get searchLabel => 'Nome do filme';

  @override
  String get searchHint => 'Digite o nome do filme';

  @override
  String get searchTooltip => 'Pesquisar';

  @override
  String get advancedFilter => 'Filtro avançado';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get genresLoadError => 'Não foi possível carregar os gêneros.';

  @override
  String get detailsFallbackTitle => 'Detalhes';

  @override
  String get detailsLoadError => 'Não foi possível carregar este filme.';

  @override
  String get detailsNotFound => 'Não encontramos informações sobre este filme.';

  @override
  String get synopsisTitle => 'Sinopse';

  @override
  String get trailerUnavailable => 'Trailer não disponível';

  @override
  String get watchProvidersTitle => 'Onde assistir';

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
  String get watchProvidersSeeWhere => 'Ver onde assistir';

  @override
  String get watchProvidersAttribution => 'Fonte: JustWatch';

  @override
  String get watchProvidersLoadError =>
      'Não foi possível carregar onde assistir';

  @override
  String get castTitle => 'Elenco';

  @override
  String get castSeeAll => 'Ver todos';

  @override
  String directedBy(String names) {
    return 'Direção: $names';
  }

  @override
  String certificationLabel(String certification) {
    return 'Classificação indicativa: $certification';
  }

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmpty =>
      'Nenhum filme nos favoritos ainda. Toque no coração na tela de um filme para salvá-lo aqui.';

  @override
  String get favoritesLoadError => 'Não foi possível carregar os favoritos.';

  @override
  String get favoriteAdd => 'Adicionar aos favoritos';

  @override
  String get favoriteRemove => 'Remover dos favoritos';

  @override
  String favoriteRemoved(String title) {
    return '$title saiu dos favoritos';
  }

  @override
  String get undo => 'Desfazer';

  @override
  String get ratingTitle => 'Sua avaliação';

  @override
  String get ratingHint => 'Já assistiu? Dê uma nota e conte como foi.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '1 estrela',
    );
    return '$_temp0';
  }

  @override
  String get moodLoved => 'Amei';

  @override
  String get moodFunny => 'Divertido';

  @override
  String get moodMoved => 'Emocionante';

  @override
  String get moodTense => 'Tenso';

  @override
  String get moodBored => 'Entediante';
}
