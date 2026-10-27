import 'package:app_filmes/utils/user_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tmdbLanguageFor', () {
    test('qualquer variante de português pede conteúdo em pt-BR', () {
      expect(tmdbLanguageFor(const [Locale('pt', 'BR')]), 'pt-BR');
      expect(tmdbLanguageFor(const [Locale('pt', 'PT')]), 'pt-BR');
    });

    test('qualquer variante de inglês pede conteúdo em en-US', () {
      expect(tmdbLanguageFor(const [Locale('en', 'GB')]), 'en-US');
    });

    test('idioma não suportado cai para en-US, como a interface', () {
      expect(tmdbLanguageFor(const [Locale('es')]), 'en-US');
    });

    test('usa o primeiro idioma suportado da lista de preferências', () {
      expect(
        tmdbLanguageFor(const [Locale('es'), Locale('pt', 'BR')]),
        'pt-BR',
      );
    });
  });
}
