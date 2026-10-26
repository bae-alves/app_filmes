
import 'package:dio/dio.dart';
import 'dart:convert';
/// Serviço responsável por interpretar as preferências do usuário com a Gemini.
class GeminiService {
  GeminiService({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio();

  final String _apiKey;
  final Dio _dio;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Interpreta o pedido e retorna critérios para recomendar filmes.
  Future<Map<String, dynamic>> interpretPreferences(String message) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Digite seu humor ou suas preferências.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/models/gemini-2.5-flash:generateContent',
      options: Options(
        headers: {
          'x-goog-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
      data: {
        'system_instruction': {
          'parts': [
            {
              'text': '''
Você é um assistente de recomendações de filmes.
Interprete o humor, os gostos e as restrições informados pelo usuário.
Responda somente com JSON válido, sem Markdown, neste formato:
{
  "genres": ["Suspense", "Drama"],
  "mood": "tenso",
  "preferences": ["suspense psicológico"],
  "avoid": ["violência excessiva"],
  "explanation": "Filmes de suspense psicológico com violência moderada."
}
Use nomes de gêneros de filmes reconhecíveis pelo TMDB.
Não invente títulos, notas, classificações etárias ou plataformas.
''',
            },
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': message},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': {
            'type': 'OBJECT',
            'properties': {
              'genres': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'},
              },
              'mood': {'type': 'STRING'},
              'preferences': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'},
              },
              'avoid': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'},
              },
              'explanation': {'type': 'STRING'},
            },
            'required': [
              'genres',
              'mood',
              'preferences',
              'avoid',
              'explanation',
            ],
          },
        },
      },
    );

    final candidates = response.data?['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('A Gemini não retornou uma interpretação.');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw Exception('A resposta da Gemini veio vazia.');
    }

    final text = parts.first['text'] as String?;
    if (text == null || text.isEmpty) {
      throw Exception('A Gemini não retornou critérios válidos.');
    }

    final decoded = _decodeJson(text);
    return decoded;
  }

  Map<String, dynamic> _decodeJson(String text) {
    // A conversão do JSON fica isolada para facilitar testes e manutenção.
    final decoded = _parseJson(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Formato de resposta inválido.');
    }
    return decoded;
  }

  dynamic _parseJson(String text) {
    // Usa o conversor padrão do Dart.
    return jsonDecode(text);
  }
}
