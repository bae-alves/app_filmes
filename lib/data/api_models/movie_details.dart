import 'package:json_annotation/json_annotation.dart';

import 'genre.dart';

part 'movie_details.g.dart';

/// Detalhes completos de um filme (`/movie/{movie_id}`).
///
/// Traz campos que a listagem não devolve, como [runtime], [genres] e
/// [tagline] — é o que alimenta a tela de detalhes.
///
/// Referência: https://developer.themoviedb.org/reference/movie-details
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieDetails {
  const MovieDetails({
    required this.id,
    this.title,
    this.originalTitle,
    this.tagline,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
    this.voteCount,
    this.genres,
    this.homepage,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsFromJson(json);

  /// Identificador do filme no TMDB.
  final int id;

  /// Título traduzido.
  final String? title;

  /// Título original.
  final String? originalTitle;

  /// Frase de efeito do filme.
  final String? tagline;

  /// Sinopse.
  final String? overview;

  /// Caminho relativo do pôster.
  final String? posterPath;

  /// Caminho relativo da imagem de fundo.
  final String? backdropPath;

  /// Data de lançamento no formato `yyyy-MM-dd`. Pode vir vazia.
  final String? releaseDate;

  /// Duração em minutos.
  final int? runtime;

  /// Nota média (0 a 10).
  final double? voteAverage;

  /// Quantidade de votos.
  final int? voteCount;

  /// Gêneros do filme.
  final List<Genre>? genres;

  /// Site oficial, quando cadastrado.
  final String? homepage;

  Map<String, dynamic> toJson() => _$MovieDetailsToJson(this);
}
