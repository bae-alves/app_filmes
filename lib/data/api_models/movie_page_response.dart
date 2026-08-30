import 'package:json_annotation/json_annotation.dart';

import 'movie.dart';

part 'movie_page_response.g.dart';

/// Envelope paginado devolvido pelos endpoints de listagem de filmes.
///
/// Referência: https://developer.themoviedb.org/reference/movie-popular-list
@JsonSerializable(fieldRename: FieldRename.snake)
class MoviePageResponse {
  const MoviePageResponse({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory MoviePageResponse.fromJson(Map<String, dynamic> json) =>
      _$MoviePageResponseFromJson(json);

  /// Página atual (a API é 1-based).
  final int? page;

  /// Filmes da página.
  final List<Movie>? results;

  /// Total de páginas disponíveis.
  final int? totalPages;

  /// Total de filmes disponíveis considerando todas as páginas.
  final int? totalResults;

  Map<String, dynamic> toJson() => _$MoviePageResponseToJson(this);
}
