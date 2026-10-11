import 'package:json_annotation/json_annotation.dart';

import 'genre.dart';

part 'movie_details.g.dart';

/// Detalhes completos de um filme (`/movie/{movie_id}`).
///
/// Traz campos que a listagem não devolve, como [runtime], [genres] e
/// [tagline] — é o que alimenta a tela de detalhes. [credits] e
/// [releaseDates] vêm na mesma requisição, via `append_to_response`.
///
/// `explicitToJson` faz o [toJson] devolver JSON puro também nos objetos
/// aninhados: é o formato guardado no cache do repositório.
///
/// Referência: https://developer.themoviedb.org/reference/movie-details
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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
    this.credits,
    this.releaseDates,
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

  /// Elenco e equipe técnica.
  final Credits? credits;

  /// Datas de lançamento e classificação indicativa por país.
  final ReleaseDatesResponse? releaseDates;

  /// Diretores do filme (há filmes com mais de um).
  List<CrewMember> get directors => [
        for (final member in credits?.crew ?? const <CrewMember>[])
          if (member.job == 'Director') member,
      ];

  /// Classificação indicativa no país [region] (ISO 3166-1, ex.: `BR`), ou
  /// `null` quando o país não tem uma cadastrada.
  ///
  /// Não cai para outro país de propósito: a classificação de um país (`PG-13`)
  /// não vale em outro (`14`).
  String? certificationFor(String region) {
    final upper = region.toUpperCase();
    for (final country in releaseDates?.results ?? const <CountryReleaseDates>[]) {
      if (country.iso31661 != upper) continue;
      for (final release in country.releaseDates ?? const <ReleaseDate>[]) {
        final certification = release.certification?.trim();
        if (certification != null && certification.isNotEmpty) {
          return certification;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => _$MovieDetailsToJson(this);
}

/// Elenco e equipe técnica de um filme (`credits` no `append_to_response`).
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Credits {
  const Credits({this.cast, this.crew});

  factory Credits.fromJson(Map<String, dynamic> json) =>
      _$CreditsFromJson(json);

  /// Elenco, na ordem de destaque definida por [CastMember.order].
  final List<CastMember>? cast;

  /// Equipe técnica (direção, roteiro, fotografia...).
  final List<CrewMember>? crew;

  Map<String, dynamic> toJson() => _$CreditsToJson(this);
}

/// Pessoa do elenco.
@JsonSerializable(fieldRename: FieldRename.snake)
class CastMember {
  const CastMember({this.name, this.character, this.profilePath, this.order});

  factory CastMember.fromJson(Map<String, dynamic> json) =>
      _$CastMemberFromJson(json);

  /// Nome do ator ou atriz.
  final String? name;

  /// Personagem interpretado.
  final String? character;

  /// Caminho relativo da foto.
  final String? profilePath;

  /// Posição nos créditos: `0` é o papel principal.
  final int? order;

  Map<String, dynamic> toJson() => _$CastMemberToJson(this);
}

/// Pessoa da equipe técnica.
@JsonSerializable(fieldRename: FieldRename.snake)
class CrewMember {
  const CrewMember({this.name, this.job});

  factory CrewMember.fromJson(Map<String, dynamic> json) =>
      _$CrewMemberFromJson(json);

  /// Nome da pessoa.
  final String? name;

  /// Função, em inglês (ex.: `Director`, `Screenplay`).
  final String? job;

  Map<String, dynamic> toJson() => _$CrewMemberToJson(this);
}

/// Lançamentos por país (`release_dates` no `append_to_response`).
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ReleaseDatesResponse {
  const ReleaseDatesResponse({this.results});

  factory ReleaseDatesResponse.fromJson(Map<String, dynamic> json) =>
      _$ReleaseDatesResponseFromJson(json);

  final List<CountryReleaseDates>? results;

  Map<String, dynamic> toJson() => _$ReleaseDatesResponseToJson(this);
}

/// Lançamentos de um filme num país.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CountryReleaseDates {
  const CountryReleaseDates({this.iso31661, this.releaseDates});

  factory CountryReleaseDates.fromJson(Map<String, dynamic> json) =>
      _$CountryReleaseDatesFromJson(json);

  /// País, em ISO 3166-1 de duas letras (`BR`, `US`...).
  @JsonKey(name: 'iso_3166_1')
  final String? iso31661;

  /// Um item por tipo de lançamento (cinema, digital...), cada um com a sua
  /// classificação — que muitas vezes vem vazia.
  final List<ReleaseDate>? releaseDates;

  Map<String, dynamic> toJson() => _$CountryReleaseDatesToJson(this);
}

/// Um lançamento do filme num país.
@JsonSerializable(fieldRename: FieldRename.snake)
class ReleaseDate {
  const ReleaseDate({this.certification});

  factory ReleaseDate.fromJson(Map<String, dynamic> json) =>
      _$ReleaseDateFromJson(json);

  /// Classificação indicativa (ex.: `14`, `L`, `PG-13`). Pode vir vazia.
  final String? certification;

  Map<String, dynamic> toJson() => _$ReleaseDateToJson(this);
}
