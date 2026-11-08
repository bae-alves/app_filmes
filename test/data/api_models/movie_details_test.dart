import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/movie_fixtures.dart';

void main() {
  group('directors', () {
    test('filtra a equipe pela função Director', () {
      expect(dunaDetails.directors.map((d) => d.name), ['Denis Villeneuve']);
    });

    test('é vazio quando não há créditos', () {
      expect(matrixDetails.directors, isEmpty);
    });
  });

  group('certificationFor', () {
    test('pula lançamentos sem classificação e aceita minúsculas', () {
      expect(dunaDetails.certificationFor('br'), '14');
      expect(dunaDetails.certificationFor('US'), 'PG-13');
    });

    test('não cai para outro país', () {
      expect(dunaDetails.certificationFor('PT'), isNull);
      expect(matrixDetails.certificationFor('BR'), isNull);
    });
  });

  test('toJson e fromJson preservam créditos e classificação', () {
    final copy = MovieDetails.fromJson(dunaDetails.toJson());

    expect(copy.credits?.cast?.length, 2);
    expect(copy.directors.single.name, 'Denis Villeneuve');
    expect(copy.certificationFor('BR'), '14');
  });
}
