import 'package:json_annotation/json_annotation.dart';

import 'video.dart';

part 'videos_response.g.dart';

/// Envelope devolvido por `/movie/{movie_id}/videos`.
@JsonSerializable(fieldRename: FieldRename.snake)
class VideosResponse {
  const VideosResponse({this.id, this.results});

  factory VideosResponse.fromJson(Map<String, dynamic> json) =>
      _$VideosResponseFromJson(json);

  /// Id do filme ao qual os vídeos pertencem.
  final int? id;

  /// Vídeos encontrados. Vem vazio quando não há nada cadastrado no idioma
  /// solicitado.
  final List<Video>? results;

  Map<String, dynamic> toJson() => _$VideosResponseToJson(this);
}
