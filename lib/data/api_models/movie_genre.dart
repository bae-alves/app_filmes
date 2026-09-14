import 'package:json_annotation/json_annotation.dart';

part 'movie_genre.g.dart';

@JsonSerializable()
class MovieGenre {
  const MovieGenre({
    required this.id,
    required this.name,
  });

  factory MovieGenre.fromJson(Map<String, dynamic> json) =>
      _$MovieGenreFromJson(json);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => _$MovieGenreToJson(this);
}