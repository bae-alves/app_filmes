import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'tmdb_rest_client.dart';

/// Cria o [Dio] configurado para conversar com o TMDB.
///
/// Fica separado do `main.dart` para que a configuração de rede (autenticação,
/// timeouts, log) seja reaproveitável e possa ser trocada em testes de
/// integração.
///
/// [readAccessToken] é o *API Read Access Token* (v4) do TMDB, enviado no
/// header `Authorization`. É a forma de autenticação recomendada pela API:
/// https://developer.themoviedb.org/docs/authentication-application
Dio createTmdbDio({
  required String readAccessToken,
  String baseUrl = tmdbBaseUrl,
  bool enableLogging = kDebugMode,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer $readAccessToken',
        'accept': 'application/json',
      },
      // Deixamos o Dio lançar DioException para status >= 400; o repositório
      // converte essas exceções em Result.error.
    ),
  );

  if (enableLogging) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  return dio;
}
