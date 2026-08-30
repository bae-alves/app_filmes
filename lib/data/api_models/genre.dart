import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

/// Gênero associado a um filme (ex.: "Ação", "Drama").
@JsonSerializable(fieldRename: FieldRename.snake)
class Genre {
  const Genre({required this.id, this.name});

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

  /// Identificador do gênero no TMDB.
  final int id;

  /// Nome já traduzido para o idioma pedido na requisição.
  final String? name;

  Map<String, dynamic> toJson() => _$GenreToJson(this);
}
