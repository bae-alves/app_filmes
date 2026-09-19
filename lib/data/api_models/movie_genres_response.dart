import 'package:json_annotation/json_annotation.dart';

import 'movie_genre.dart';

part 'movie_genres_response.g.dart';

@JsonSerializable()
class MovieGenresResponse {
  const MovieGenresResponse({
    this.genres,
  });

  factory MovieGenresResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieGenresResponseFromJson(json);

  final List<MovieGenre>? genres;

  Map<String, dynamic> toJson() => _$MovieGenresResponseToJson(this);
}