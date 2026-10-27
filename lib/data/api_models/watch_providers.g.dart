// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_providers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchProvidersResponse _$WatchProvidersResponseFromJson(
  Map<String, dynamic> json,
) => WatchProvidersResponse(
  id: (json['id'] as num?)?.toInt(),
  results: (json['results'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, WatchProviderRegion.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$WatchProvidersResponseToJson(
  WatchProvidersResponse instance,
) => <String, dynamic>{'id': instance.id, 'results': instance.results};

WatchProviderRegion _$WatchProviderRegionFromJson(Map<String, dynamic> json) =>
    WatchProviderRegion(
      link: json['link'] as String?,
      flatrate: (json['flatrate'] as List<dynamic>?)
          ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      free: (json['free'] as List<dynamic>?)
          ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      ads: (json['ads'] as List<dynamic>?)
          ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      rent: (json['rent'] as List<dynamic>?)
          ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      buy: (json['buy'] as List<dynamic>?)
          ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchProviderRegionToJson(
  WatchProviderRegion instance,
) => <String, dynamic>{
  'link': instance.link,
  'flatrate': instance.flatrate,
  'free': instance.free,
  'ads': instance.ads,
  'rent': instance.rent,
  'buy': instance.buy,
};

WatchProvider _$WatchProviderFromJson(Map<String, dynamic> json) =>
    WatchProvider(
      providerId: (json['provider_id'] as num?)?.toInt(),
      providerName: json['provider_name'] as String?,
      logoPath: json['logo_path'] as String?,
      displayPriority: (json['display_priority'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WatchProviderToJson(WatchProvider instance) =>
    <String, dynamic>{
      'provider_id': instance.providerId,
      'provider_name': instance.providerName,
      'logo_path': instance.logoPath,
      'display_priority': instance.displayPriority,
    };
