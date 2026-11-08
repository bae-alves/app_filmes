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
  credits: json['credits'] == null
      ? null
      : Credits.fromJson(json['credits'] as Map<String, dynamic>),
  releaseDates: json['release_dates'] == null
      ? null
      : ReleaseDatesResponse.fromJson(
          json['release_dates'] as Map<String, dynamic>,
        ),
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
      'genres': instance.genres?.map((e) => e.toJson()).toList(),
      'homepage': instance.homepage,
      'credits': instance.credits?.toJson(),
      'release_dates': instance.releaseDates?.toJson(),
    };

Credits _$CreditsFromJson(Map<String, dynamic> json) => Credits(
  cast: (json['cast'] as List<dynamic>?)
      ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  crew: (json['crew'] as List<dynamic>?)
      ?.map((e) => CrewMember.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreditsToJson(Credits instance) => <String, dynamic>{
  'cast': instance.cast?.map((e) => e.toJson()).toList(),
  'crew': instance.crew?.map((e) => e.toJson()).toList(),
};

CastMember _$CastMemberFromJson(Map<String, dynamic> json) => CastMember(
  name: json['name'] as String?,
  character: json['character'] as String?,
  profilePath: json['profile_path'] as String?,
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CastMemberToJson(CastMember instance) =>
    <String, dynamic>{
      'name': instance.name,
      'character': instance.character,
      'profile_path': instance.profilePath,
      'order': instance.order,
    };

CrewMember _$CrewMemberFromJson(Map<String, dynamic> json) =>
    CrewMember(name: json['name'] as String?, job: json['job'] as String?);

Map<String, dynamic> _$CrewMemberToJson(CrewMember instance) =>
    <String, dynamic>{'name': instance.name, 'job': instance.job};

ReleaseDatesResponse _$ReleaseDatesResponseFromJson(
  Map<String, dynamic> json,
) => ReleaseDatesResponse(
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => CountryReleaseDates.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReleaseDatesResponseToJson(
  ReleaseDatesResponse instance,
) => <String, dynamic>{
  'results': instance.results?.map((e) => e.toJson()).toList(),
};

CountryReleaseDates _$CountryReleaseDatesFromJson(Map<String, dynamic> json) =>
    CountryReleaseDates(
      iso31661: json['iso_3166_1'] as String?,
      releaseDates: (json['release_dates'] as List<dynamic>?)
          ?.map((e) => ReleaseDate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CountryReleaseDatesToJson(
  CountryReleaseDates instance,
) => <String, dynamic>{
  'iso_3166_1': instance.iso31661,
  'release_dates': instance.releaseDates?.map((e) => e.toJson()).toList(),
};

ReleaseDate _$ReleaseDateFromJson(Map<String, dynamic> json) =>
    ReleaseDate(certification: json['certification'] as String?);

Map<String, dynamic> _$ReleaseDateToJson(ReleaseDate instance) =>
    <String, dynamic>{'certification': instance.certification};
