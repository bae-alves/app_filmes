import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/recommendation_context.dart';


class GeminiService {
  GeminiService({required String Function() apiKey, Dio? dio})
    : _apiKey = apiKey,
      _dio = dio ?? Dio();

  /// Lida só ao enviar uma mensagem: a chave serve apenas ao chat, e o app
  /// precisa abrir mesmo sem ela no `.env`.
  final String Function() _apiKey;
  final Dio _dio;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

    Future<Map<String, dynamic>> interpretPreferences(
      String message, {
      RecommendationContext? context,
    }) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Digite seu humor ou suas preferências.');
    }
    final contextInformation = context?.toPromptContext() ??
    'Não há informações históricas disponíveis para este usuário.';


    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/models/gemini-2.5-flash:generateContent',
      options: Options(
        headers: {
          'x-goog-api-key': _apiKey(),
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

              Você é um assistente inteligente de recomendações de filmes.

              Sua função é interpretar o pedido atual do usuário e combinar
              suas preferências com seu histórico de avaliações e contexto temporal.

              Considere as seguintes regras:

              1. GÊNEROS FAVORITOS:
              Dê preferência aos gêneros que possuem avaliações positivas
              e que aparecem frequentemente nos filmes favoritos.

              2. GÊNEROS MENOS APRECIADOS:
              Evite sugerir gêneros que receberam avaliações negativas,
              a menos que o usuário solicite explicitamente esses gêneros.

              3. HISTÓRICO:
              Considere as avaliações recentes e as reações emocionais
              para compreender os gostos do usuário.

              4. CONTEXTO TEMPORAL:
              Considere o dia da semana e o horário local.
              Em noites de dias úteis, priorize filmes mais curtos,
              que sejam adequados para assistir após um dia de trabalho.
              Nos finais de semana, considere também filmes mais longos.

              5. PRIORIDADE DO PEDIDO:
              O pedido atual do usuário sempre tem prioridade sobre
              as preferências históricas.
              Não recomende um gênero que o usuário explicitamente
              pediu para evitar.

              6. DURAÇÃO:
              Classifique a duração desejada em:
              - short: até 90 minutos
              - medium: de 91 a 120 minutos
              - long: acima de 120 minutos
              - any: sem preferência de duração

              Não invente títulos, notas, classificações etárias,
              durações ou plataformas.

              Responda somente com JSON válido, sem Markdown,
              neste formato:

              {
                "genres": ["Comédia", "Animação"],
                "mood": "descontraído",
                "preferences": ["filme leve"],
                "avoid": ["terror"],
                "durationPreference": "short",
                "explanation": "Sugestões leves para relaxar durante a noite."
              }

              Use nomes de gêneros reconhecíveis pelo TMDB.''',
            },
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': '''
            Contexto personalizado do usuário:

            $contextInformation

            Pedido atual:
            $message
            ''',
                  },
                ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': {
            'type': 'OBJECT',
            'properties': {
              'durationPreference': {
                'type': 'STRING',
                'enum': ['short', 'medium', 'long', 'any'],
              },
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
              'durationPreference',
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
