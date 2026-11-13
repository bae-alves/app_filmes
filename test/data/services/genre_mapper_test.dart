import 'package:app_filmes/data/services/genre_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenreMapper', () {
    test('mapeia nomes em português com e sem acentos', () {
      expect(GenreMapper.findGenreId('Comédia'), equals(35));
      expect(GenreMapper.findGenreId('comedia'), equals(35));
      expect(GenreMapper.findGenreId('Ação'), equals(28));
      expect(GenreMapper.findGenreId('acao'), equals(28));
      expect(GenreMapper.findGenreId('Animação'), equals(16));
      expect(GenreMapper.findGenreId('Ficção Científica'), equals(878));
      expect(GenreMapper.findGenreId('ficcao cientifica'), equals(878));
    });

    test('mapeia nomes em inglês', () {
      expect(GenreMapper.findGenreId('Comedy'), equals(35));
      expect(GenreMapper.findGenreId('Action'), equals(28));
      expect(GenreMapper.findGenreId('Animation'), equals(16));
      expect(GenreMapper.findGenreId('Science Fiction'), equals(878));
      expect(GenreMapper.findGenreId('Thriller'), equals(53));
    });

    test('mapeia sinônimos comuns', () {
      expect(GenreMapper.findGenreId('sci-fi'), equals(878));
      expect(GenreMapper.findGenreId('desenho'), equals(16));
      expect(GenreMapper.findGenreId('suspense'), equals(53));
      expect(GenreMapper.findGenreId('terror'), equals(27));
      expect(GenreMapper.findGenreId('horror'), equals(27));
      expect(GenreMapper.findGenreId('faroeste'), equals(37));
    });

    test('converte lista de gêneros brutos em IDs sem duplicatas', () {
      final ids = GenreMapper.toGenreIds([
        'Comédia',
        'Comedy',
        'Ação',
        'Terror',
      ]);
      expect(ids, containsAll([35, 28, 27]));
      expect(ids.length, equals(3));
    });
  });
}
