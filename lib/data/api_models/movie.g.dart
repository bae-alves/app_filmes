// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  originalTitle: json['original_title'] as String?,
  overview: json['overview'] as String?,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  releaseDate: json['release_date'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
  voteCount: (json['vote_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'original_title': instance.originalTitle,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
  'release_date': instance.releaseDate,
  'vote_average': instance.voteAverage,
  'vote_count': instance.voteCount,
};
