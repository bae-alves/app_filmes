import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

/// Vídeo vinculado a um filme: trailer, teaser, cena de bastidores etc.
///
/// Referência: https://developer.themoviedb.org/reference/movie-videos
@JsonSerializable(fieldRename: FieldRename.snake)
class Video {
  const Video({
    this.id,
    this.name,
    this.key,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  /// Identificador do vídeo no TMDB (string, diferente do id do filme).
  final String? id;

  /// Título do vídeo (ex.: "Trailer Oficial Dublado").
  final String? name;

  /// Identificador do vídeo no site de origem. Para o YouTube, é o que vai
  /// depois de `watch?v=` — é essa chave que o player consome.
  final String? key;

  /// Site que hospeda o vídeo: normalmente `YouTube`, às vezes `Vimeo`.
  final String? site;

  /// Resolução vertical (360, 480, 720, 1080).
  final int? size;

  /// Categoria do vídeo: `Trailer`, `Teaser`, `Clip`, `Featurette`...
  final String? type;

  /// Indica se o vídeo foi publicado pelo canal oficial do filme.
  final bool? official;

  /// Data de publicação em ISO 8601.
  final String? publishedAt;

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
