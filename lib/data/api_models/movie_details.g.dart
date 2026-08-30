// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieDetails _$MovieDetailsFromJson(Map<String, dynamic> json) => MovieDetails(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  originalTitle: json['original_title'] as String?,
  tagline: json['tagline'] as String?,
  overview: json['overview'] as String?,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  releaseDate: json['release_date'] as String?,
  runtime: (json['runtime'] as num?)?.toInt(),
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
  voteCount: (json['vote_count'] as num?)?.toInt(),
  genres: (json['genres'] as List<dynamic>?)
      ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
      .toList(),
  homepage: json['homepage'] as String?,
);

Map<String, dynamic> _$MovieDetailsToJson(MovieDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'tagline': instance.tagline,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'release_date': instance.releaseDate,
      'runtime': instance.runtime,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'genres': instance.genres,
      'homepage': instance.homepage,
    };
