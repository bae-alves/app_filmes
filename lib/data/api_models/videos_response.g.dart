// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videos_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideosResponse _$VideosResponseFromJson(Map<String, dynamic> json) =>
    VideosResponse(
      id: (json['id'] as num?)?.toInt(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideosResponseToJson(VideosResponse instance) =>
    <String, dynamic>{'id': instance.id, 'results': instance.results};
