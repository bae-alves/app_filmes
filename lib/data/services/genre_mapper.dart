/// Serviço de padronização e mapeamento de gêneros do cinema.
///
/// Mapeia nomes de gêneros em múltiplos idiomas (Português, Inglês), com ou sem
/// acentuação e variações de grafia, diretamente para os IDs numéricos oficiais
/// da API do TMDB.
abstract final class GenreMapper {
  /// Converte uma lista de nomes de gêneros (em PT ou EN) para os IDs numéricos do TMDB.
  static List<int> toGenreIds(List<String> rawGenres) {
    final ids = <int>{};
    for (final raw in rawGenres) {
      final id = findGenreId(raw);
      if (id != null) {
        ids.add(id);
      }
    }
    return ids.toList();
  }

  /// Procura o ID numérico do TMDB para um nome de gênero ou sinônimo.
  static int? findGenreId(String genreName) {
    final query = normalize(genreName);
    if (query.isEmpty) return null;

    // 1. Busca por correspondência exata primeiro.
    for (final entry in _tmdbGenres.entries) {
      for (final alias in entry.value) {
        if (normalize(alias) == query) {
          return entry.key;
        }
      }
    }

    // 2. Busca por subsequência quando a palavra tem tamanho suficiente.
    for (final entry in _tmdbGenres.entries) {
      for (final alias in entry.value) {
        final normAlias = normalize(alias);
        if (normAlias.length >= 4 &&
            query.length >= 4 &&
            (normAlias.contains(query) || query.contains(normAlias))) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Normaliza o texto removendo acentos, caracteres especiais e espaços extras.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Mapa oficial de IDs de gêneros do TMDB e seus sinônimos/traduções.
  static const Map<int, List<String>> _tmdbGenres = {
    28: ['Ação', 'Action', 'Acao', 'Filme de Ação'],
    12: ['Aventura', 'Adventure'],
    16: [
      'Animação',
      'Animation',
      'Animacao',
      'Desenho',
      'Desenho Animado',
      'Anime',
    ],
    35: ['Comédia', 'Comedy', 'Comedia', 'Engraçado', 'Humor', 'Divertido'],
    80: ['Crime', 'Policial', 'Criminoso'],
    99: ['Documentário', 'Documentary', 'Documentario', 'Doc'],
    18: ['Drama', 'Dramático', 'Emocionante'],
    10751: ['Família', 'Family', 'Familia', 'Infantil', 'Kids'],
    14: ['Fantasia', 'Fantasy', 'Magia'],
    36: ['História', 'History', 'Historia', 'Histórico'],
    27: ['Terror', 'Horror', 'Medo', 'Assustador'],
    10402: ['Música', 'Music', 'Musica', 'Musical'],
    9648: ['Mistério', 'Mystery', 'Misterio', 'Investigação'],
    10749: ['Romance', 'Romântico', 'Amor'],
    878: [
      'Ficção Científica',
      'Science Fiction',
      'Ficcao Cientifica',
      'Ficção',
      'Sci-Fi',
      'Scifi',
    ],
    10770: ['Cinema TV', 'TV Movie', 'Filme para TV'],
    53: ['Suspense', 'Thriller', 'Tensão', 'Tenso'],
    10752: ['Guerra', 'War', 'Militar'],
    37: ['Faroeste', 'Western', 'Bang Bang', 'Cowboy'],
  };
}
