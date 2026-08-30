import 'package:app_filmes/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      expect(formatRuntime(166), '2h 46min');
    });

    test('omite os minutos quando a duração é exata em horas', () {
      expect(formatRuntime(120), '2h');
    });

    test('mostra apenas minutos para filmes com menos de uma hora', () {
      expect(formatRuntime(45), '45min');
    });

    test('devolve null para duração ausente ou inválida', () {
      expect(formatRuntime(null), isNull);
      expect(formatRuntime(0), isNull);
    });
  });

  group('formatRating', () {
    test('usa uma casa decimal e vírgula como separador', () {
      expect(formatRating(8.234), '8,2');
    });

    test('devolve null quando o filme ainda não tem votos', () {
      expect(formatRating(null), isNull);
      expect(formatRating(0), isNull);
    });
  });
}
