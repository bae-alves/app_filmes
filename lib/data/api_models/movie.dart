import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

/// Resumo de um filme, como devolvido pelos endpoints de listagem do TMDB
/// (ex.: `/movie/popular`).
///
/// Modelos de API espelham o JSON do serviço: nada de regra de negócio aqui.
/// O `fieldRename` converte `snake_case` do JSON para `camelCase` do Dart.
@JsonSerializable(fieldRename: FieldRename.snake)
class Movie {
  const Movie({
    required this.id,
    this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  /// Identificador do filme no TMDB, usado para buscar detalhes e vídeos.
  final int id;

  /// Título traduzido para o idioma pedido na requisição.
  final String? title;

  /// Título original, no idioma de produção do filme.
  final String? originalTitle;

  /// Sinopse.
  final String? overview;

  /// Caminho relativo do pôster. Combine com `TmdbImages.poster`.
  final String? posterPath;

  /// Caminho relativo da imagem de fundo. Combine com `TmdbImages.backdrop`.
  final String? backdropPath;

  /// Data de lançamento no formato `yyyy-MM-dd`. Pode vir vazia.
  final String? releaseDate;

  /// Nota média (0 a 10).
  final double? voteAverage;

  /// Quantidade de votos que compõem a [voteAverage].
  final int? voteCount;

  final List<int>? genreIds;

  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
