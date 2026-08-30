/// Monta as URLs do servidor de imagens do TMDB.
///
/// A API devolve apenas o caminho relativo do arquivo (ex.: `/abc123.jpg`);
/// o host e o tamanho desejado são responsabilidade do cliente.
/// Referência: https://developer.themoviedb.org/docs/image-basics
abstract final class TmdbImages {
  static const _baseUrl = 'https://image.tmdb.org/t/p';

  /// URL do pôster no tamanho [size] (`w185`, `w342`, `w500`, `original`...).
  ///
  /// Retorna `null` quando o filme não possui imagem cadastrada, para que a
  /// view possa exibir um placeholder.
  static String? poster(String? path, {String size = 'w342'}) =>
      _build(path, size);

  /// URL da imagem de fundo (cena do filme) no tamanho [size].
  static String? backdrop(String? path, {String size = 'w780'}) =>
      _build(path, size);

  static String? _build(String? path, String size) {
    if (path == null || path.isEmpty) return null;
    // A API já devolve o caminho com "/" inicial, mas normalizamos para não
    // gerar URL com barra dupla caso isso mude.
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$_baseUrl/$size$normalized';
  }
}
