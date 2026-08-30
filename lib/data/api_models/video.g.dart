// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String?,
  name: json['name'] as String?,
  key: json['key'] as String?,
  site: json['site'] as String?,
  size: (json['size'] as num?)?.toInt(),
  type: json['type'] as String?,
  official: json['official'] as bool?,
  publishedAt: json['published_at'] as String?,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'key': instance.key,
  'site': instance.site,
  'size': instance.size,
  'type': instance.type,
  'official': instance.official,
  'published_at': instance.publishedAt,
};
