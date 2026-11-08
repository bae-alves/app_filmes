import 'package:app_filmes/l10n/app_localizations.dart';
import 'package:app_filmes/utils/formatters.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Traduções carregadas sem montar widget: `lookupAppLocalizations` é gerado
  // pelo gen-l10n junto com `AppLocalizations`.
  final pt = lookupAppLocalizations(const Locale('pt'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('formatReleaseYear', () {
    test('extrai o ano de uma data no formato do TMDB', () {
      expect(formatReleaseYear('2024-02-27'), '2024');
    });

    test('devolve null quando a data está ausente ou vazia', () {
      expect(formatReleaseYear(null), isNull);
      expect(formatReleaseYear(''), isNull);
    });

    test('devolve null quando o ano não é numérico', () {
      expect(formatReleaseYear('data-invalida'), isNull);
    });
  });

  group('formatRuntime', () {
    test('formata horas e minutos', () {
      expect(formatRuntime(166, pt), '2h 46min');
      expect(formatRuntime(166, en), '2h 46m');
    });

    test('omite os minutos quando a duração é exata em horas', () {
      expect(formatRuntime(120, pt), '2h');
      expect(formatRuntime(120, en), '2h');
    });

    test('mostra apenas minutos para filmes com menos de uma hora', () {
      expect(formatRuntime(45, pt), '45min');
      expect(formatRuntime(45, en), '45m');
    });

    test('devolve null para duração ausente ou inválida', () {
      expect(formatRuntime(null, pt), isNull);
      expect(formatRuntime(0, pt), isNull);
    });
  });

  group('formatRating', () {
    test('usa uma casa decimal e o separador do idioma', () {
      expect(formatRating(8.234, 'pt'), '8,2');
      expect(formatRating(8.234, 'en'), '8.2');
    });

    test('mantém a casa decimal mesmo em nota redonda', () {
      expect(formatRating(7.0, 'pt'), '7,0');
    });

    test('devolve null quando o filme ainda não tem votos', () {
      expect(formatRating(null, 'pt'), isNull);
      expect(formatRating(0, 'pt'), isNull);
    });
  });
}
