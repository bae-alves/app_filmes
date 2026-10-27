import 'package:json_annotation/json_annotation.dart';

part 'watch_providers.g.dart';

/// Envelope devolvido por `/movie/{movie_id}/watch/providers`.
///
/// Os dados de disponibilidade em streaming são fornecidos ao TMDB pela
/// JustWatch — por isso a interface precisa exibir o crédito "JustWatch"
/// sempre que mostrar estas informações (exigência dos termos do TMDB).
///
/// Referência: https://developer.themoviedb.org/reference/movie-watch-providers
@JsonSerializable(fieldRename: FieldRename.snake)
class WatchProvidersResponse {
  const WatchProvidersResponse({this.id, this.results});

  factory WatchProvidersResponse.fromJson(Map<String, dynamic> json) =>
      _$WatchProvidersResponseFromJson(json);

  /// Id do filme ao qual os provedores pertencem.
  final int? id;

  /// Disponibilidade por país, indexada pelo código ISO 3166-1 de duas letras
  /// (`BR`, `US`, `PT`...). Países em que o filme não está em nenhum serviço
  /// simplesmente não aparecem no mapa.
  final Map<String, WatchProviderRegion>? results;

  Map<String, dynamic> toJson() => _$WatchProvidersResponseToJson(this);
}

/// Onde o filme pode ser assistido em um país específico.
///
/// O TMDB separa os serviços pela forma de acesso. Um mesmo serviço pode
/// aparecer em mais de uma lista (ex.: Apple TV em [rent] e em [buy]).
@JsonSerializable(fieldRename: FieldRename.snake)
class WatchProviderRegion {
  const WatchProviderRegion({
    this.link,
    this.flatrate,
    this.free,
    this.ads,
    this.rent,
    this.buy,
  });

  factory WatchProviderRegion.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderRegionFromJson(json);

  /// Página "onde assistir" do filme no site do TMDB, já filtrada pelo país.
  ///
  /// É o único link que a API oferece: não há deep link por serviço. A página
  /// do TMDB, por sua vez, leva a cada um dos serviços listados.
  final String? link;

  /// Serviços em que o filme está incluído na assinatura (Netflix, Max...).
  final List<WatchProvider>? flatrate;

  /// Serviços em que o filme é gratuito.
  final List<WatchProvider>? free;

  /// Serviços em que o filme é gratuito, mas com anúncios.
  final List<WatchProvider>? ads;

  /// Serviços em que o filme pode ser alugado.
  final List<WatchProvider>? rent;

  /// Serviços em que o filme pode ser comprado.
  final List<WatchProvider>? buy;

  /// `true` quando nenhuma das listas tem serviço. O TMDB às vezes devolve o
  /// país só com o [link]; para o usuário, isso equivale a "indisponível".
  bool get isEmpty => [flatrate, free, ads, rent, buy]
      .every((providers) => providers == null || providers.isEmpty);

  Map<String, dynamic> toJson() => _$WatchProviderRegionToJson(this);
}

/// Um serviço de streaming, aluguel ou compra de filmes.
@JsonSerializable(fieldRename: FieldRename.snake)
class WatchProvider {
  const WatchProvider({
    this.providerId,
    this.providerName,
    this.logoPath,
    this.displayPriority,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderFromJson(json);

  /// Identificador do serviço no TMDB (ex.: 8 é a Netflix).
  final int? providerId;

  /// Nome de exibição do serviço.
  final String? providerName;

  /// Caminho relativo do logo; monte a URL com `TmdbImages.logo`.
  final String? logoPath;

  /// Ordem sugerida pelo TMDB para exibição: menor aparece primeiro.
  final int? displayPriority;

  Map<String, dynamic> toJson() => _$WatchProviderToJson(this);
}
