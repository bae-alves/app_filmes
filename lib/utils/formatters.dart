/// Funções puras de formatação usadas pela camada de UI.
///
/// Ficam isoladas aqui porque são regra de apresentação (não de negócio) e
/// porque, sendo puras, são baratas de testar.
library;

/// Extrai o ano de uma data do TMDB no formato `yyyy-MM-dd`.
///
/// A API devolve string vazia quando a data de lançamento é desconhecida, daí
/// o retorno anulável.
String? formatReleaseYear(String? releaseDate) {
  if (releaseDate == null || releaseDate.length < 4) return null;
  final year = releaseDate.substring(0, 4);
  return int.tryParse(year) == null ? null : year;
}

/// Converte a duração em minutos para o formato `2h 15min`.
///
/// Filmes com menos de uma hora saem apenas como `45min`.
String? formatRuntime(int? minutes) {
  if (minutes == null || minutes <= 0) return null;
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '${rest}min';
  if (rest == 0) return '${hours}h';
  return '${hours}h ${rest}min';
}

/// Formata a nota média do TMDB com uma casa decimal (ex.: `7,8`).
///
/// Filmes sem votos chegam com nota `0`; nesse caso não faz sentido exibir a
/// nota, então devolvemos `null`.
String? formatRating(double? voteAverage) {
  if (voteAverage == null || voteAverage <= 0) return null;
  return voteAverage.toStringAsFixed(1).replaceAll('.', ',');
}
