/// Funções puras de formatação usadas pela camada de UI.
///
/// Ficam isoladas aqui porque são regra de apresentação (não de negócio) e
/// porque, sendo puras, são baratas de testar. As que dependem do idioma
/// recebem o idioma (ou as traduções) por parâmetro, em vez de ler o
/// `BuildContext`: assim o teste não precisa montar widget.
library;

import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// Extrai o ano de uma data do TMDB no formato `yyyy-MM-dd`.
///
/// A API devolve string vazia quando a data de lançamento é desconhecida, daí
/// o retorno anulável.
String? formatReleaseYear(String? releaseDate) {
  if (releaseDate == null || releaseDate.length < 4) return null;
  final year = releaseDate.substring(0, 4);
  return int.tryParse(year) == null ? null : year;
}

/// Converte a duração em minutos para o formato do idioma de [l10n]
/// (`2h 15min` em português, `2h 15m` em inglês).
///
/// Filmes com menos de uma hora saem só com os minutos, e durações exatas só
/// com as horas.
String? formatRuntime(int? minutes, AppLocalizations l10n) {
  if (minutes == null || minutes <= 0) return null;
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return l10n.runtimeMinutes(rest);
  if (rest == 0) return l10n.runtimeHours(hours);
  return l10n.runtimeHoursMinutes(hours, rest);
}

/// Formata a nota média do TMDB com uma casa decimal, usando o separador
/// decimal de [locale] (`7,8` em `pt`, `7.8` em `en`).
///
/// [locale] é o nome da localidade no formato do `intl` (`pt`, `en_US`...);
/// na view, use `Localizations.localeOf(context).toString()`.
///
/// Filmes sem votos chegam com nota `0`; nesse caso não faz sentido exibir a
/// nota, então devolvemos `null`.
String? formatRating(double? voteAverage, String locale) {
  if (voteAverage == null || voteAverage <= 0) return null;
  return NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1)
      .format(voteAverage);
}
