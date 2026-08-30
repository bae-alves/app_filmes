import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acesso tipado às variáveis de ambiente do arquivo `.env`.
///
/// As credenciais do TMDB não ficam versionadas: o `.env` está no `.gitignore`
/// e é declarado como asset no `pubspec.yaml` para ser lido em tempo de
/// execução. Concentrar a leitura aqui evita `dotenv.env['...']` espalhado pelo
/// código e permite falhar cedo, com mensagem clara, quando falta alguma chave.
abstract final class Env {
  /// Nome do arquivo de ambiente carregado no boot da aplicação.
  static const envFileName = '.env';

  /// Carrega o `.env`. Deve ser chamado uma única vez, antes de `runApp`.
  static Future<void> load() => dotenv.load(fileName: envFileName);

  /// Token de leitura (API Read Access Token, v4) usado no header
  /// `Authorization: Bearer ...` das chamadas ao TMDB.
  static String get tmdbReadToken => _require('TMDB_READ');

  /// Chave de API v3. Mantida para endpoints/ferramentas que ainda usam o
  /// parâmetro `api_key`; a autenticação padrão do app é via [tmdbReadToken].
  static String get tmdbApiKey => _require('TMDB_API_KEY');

  static String _require(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'A variável "$key" não foi encontrada em "$envFileName". '
        'Copie o arquivo .env.example para .env e preencha suas credenciais '
        'do TMDB (https://www.themoviedb.org/settings/api).',
      );
    }
    return value;
  }
}
