import 'dart:convert';

import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/movie_page_response.dart';
import 'package:app_filmes/data/api_models/video.dart';
import 'package:app_filmes/data/api_models/videos_response.dart';
import 'package:app_filmes/data/api_models/watch_providers.dart';
import 'package:app_filmes/data/repositories/movies_repository_remote.dart';
import 'package:app_filmes/data/services/tmdb_rest_client.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/fake_tmdb_rest_client.dart';
import '../../fakes/movie_fixtures.dart';

/// Idioma do conteúdo usado pelo repositório na maior parte dos testes.
const appLanguage = 'pt-BR';

void main() {
  late FakeTmdbRestClient restClient;
  late SharedPreferences preferences;
  late MoviesRepositoryRemote repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    restClient = FakeTmdbRestClient();
    repository = MoviesRepositoryRemote(
      restClient: restClient,
      language: appLanguage,
      preferences: preferences,
    );
  });

  group('getPopularMovies', () {
    test('devolve os filmes da resposta do serviço', () async {
      restClient.popularPage = const MoviePageResponse(
        page: 1,
        results: [dunaMovie, matrixMovie],
      );

      final result = await repository.getPopularMovies();

      expect(result, isA<Ok<List<Movie>>>());
      expect((result as Ok<List<Movie>>).value, hasLength(2));
      expect(result.value.first.title, 'Duna: Parte Dois');
    });

    test('usa o cache na segunda chamada e refaz a requisição com forceRefresh',
        () async {
      restClient.popularPage = const MoviePageResponse(results: [dunaMovie]);

      await repository.getPopularMovies();
      await repository.getPopularMovies();
      expect(restClient.popularCallCount, 1);

      await repository.getPopularMovies(forceRefresh: true);
      expect(restClient.popularCallCount, 2);
    });

    test('devolve Error quando o status HTTP não é de sucesso', () async {
      restClient.statusCode = 401;

      final result = await repository.getPopularMovies();

      expect(result, isA<Error<List<Movie>>>());
      expect((result as Error<List<Movie>>).error.toString(), contains('401'));
    });

    test('converte falha de rede em Error', () async {
      restClient.errorToThrow = DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: RequestOptions(path: '/movie/popular'),
      );

      final result = await repository.getPopularMovies();

      expect(result, isA<Error<List<Movie>>>());
    });
  });

  group('getMovieDetails', () {
    test('devolve os detalhes e guarda em cache', () async {
      restClient.details = dunaDetails;

      final first = await repository.getMovieDetails(dunaId);
      final second = await repository.getMovieDetails(dunaId);

      expect(first, isA<Ok<MovieDetails>>());
      expect((second as Ok<MovieDetails>).value.title, 'Duna: Parte Dois');
      expect(restClient.detailsCallCount, 1);
    });

    test('o cache sobrevive a uma nova instância (reinício do app)', () async {
      restClient.details = dunaDetails;
      await repository.getMovieDetails(dunaId);

      final restarted = MoviesRepositoryRemote(
        restClient: restClient,
        language: appLanguage,
        preferences: preferences,
      );
      final result = await restarted.getMovieDetails(dunaId);

      final details = (result as Ok<MovieDetails>).value;
      expect(restClient.detailsCallCount, 1);
      expect(details.directors.single.name, 'Denis Villeneuve');
      expect(details.certificationFor('BR'), '14');
    });

    test('busca de novo quando o cache passou de 24h', () async {
      final expired = DateTime.now()
          .subtract(MoviesRepositoryRemote.detailsCacheTtl)
          .subtract(const Duration(minutes: 1));
      SharedPreferences.setMockInitialValues({
        'movie_details:$appLanguage:$dunaId': jsonEncode({
          'savedAt': expired.millisecondsSinceEpoch,
          'details': matrixDetails.toJson(),
        }),
      });
      final stale = MoviesRepositoryRemote(
        restClient: restClient..details = dunaDetails,
        language: appLanguage,
        preferences: await SharedPreferences.getInstance(),
      );

      final result = await stale.getMovieDetails(dunaId);

      expect(restClient.detailsCallCount, 1);
      expect((result as Ok<MovieDetails>).value.title, 'Duna: Parte Dois');
    });

    test('apaga do aparelho as entradas vencidas ao ser criado', () async {
      final expired = DateTime.now().subtract(const Duration(days: 2));
      SharedPreferences.setMockInitialValues({
        // De outro filme e outro idioma: some mesmo sem ser pedida de novo.
        'movie_details:en-US:$matrixId': jsonEncode({
          'savedAt': expired.millisecondsSinceEpoch,
          'details': matrixDetails.toJson(),
        }),
        'outra_preferencia': 'fica',
      });
      final storage = await SharedPreferences.getInstance();

      MoviesRepositoryRemote(
        restClient: restClient,
        language: appLanguage,
        preferences: storage,
      );

      expect(storage.getKeys(), {'outra_preferencia'});
    });

    test('separa o cache por idioma', () async {
      restClient.details = dunaDetails;
      await repository.getMovieDetails(dunaId);

      final english = MoviesRepositoryRemote(
        restClient: restClient,
        language: 'en-US',
        preferences: preferences,
      );
      await english.getMovieDetails(dunaId);

      expect(restClient.detailsCallCount, 2);
    });

    test('ignora uma entrada corrompida no cache', () async {
      await preferences.setString('movie_details:$appLanguage:$dunaId', '{');
      restClient.details = dunaDetails;

      final result = await repository.getMovieDetails(dunaId);

      expect(result, isA<Ok<MovieDetails>>());
      expect(restClient.detailsCallCount, 1);
    });

    test('devolve Error quando o serviço falha', () async {
      restClient.errorToThrow = Exception('boom');

      final result = await repository.getMovieDetails(dunaId);

      expect(result, isA<Error<MovieDetails>>());
    });
  });

  group('getMovieTrailer', () {
    test('prefere o trailer oficial do YouTube', () async {
      restClient.videosByLanguage = {
        appLanguage: const VideosResponse(
          results: [
            Video(key: 'clipe', site: 'YouTube', type: 'Clip', official: true),
            Video(key: 'teaser', site: 'YouTube', type: 'Teaser', official: true),
            Video(key: 'naoOficial', site: 'YouTube', type: 'Trailer', official: false),
            Video(key: 'oficial', site: 'YouTube', type: 'Trailer', official: true),
          ],
        ),
      };

      final result = await repository.getMovieTrailer(dunaId);

      expect((result as Ok<Video?>).value?.key, 'oficial');
    });

    test('ignora vídeos que não são do YouTube ou estão sem chave', () async {
      restClient.videosByLanguage = {
        appLanguage: const VideosResponse(
          results: [
            Video(key: 'vimeo', site: 'Vimeo', type: 'Trailer', official: true),
            Video(key: '', site: 'YouTube', type: 'Trailer', official: true),
          ],
        ),
      };

      final result = await repository.getMovieTrailer(dunaId);

      expect((result as Ok<Video?>).value, isNull);
    });

    test('cai para o idioma original quando não há vídeo em pt-BR', () async {
      restClient.videosByLanguage = {
        tmdbFallbackLanguage: const VideosResponse(results: [dunaTrailer]),
      };

      final result = await repository.getMovieTrailer(dunaId);

      expect(
        restClient.requestedVideoLanguages,
        [appLanguage, tmdbFallbackLanguage],
      );
      expect((result as Ok<Video?>).value?.key, dunaTrailer.key);
    });

    test('não busca o idioma alternativo quando pt-BR já tem vídeo', () async {
      restClient.videosByLanguage = {
        appLanguage: const VideosResponse(results: [dunaTrailer]),
      };

      await repository.getMovieTrailer(dunaId);

      expect(restClient.requestedVideoLanguages, [appLanguage]);
    });

    test('devolve Ok com null quando o filme não tem nenhum vídeo', () async {
      final result = await repository.getMovieTrailer(matrixId);

      expect(result, isA<Ok<Video?>>());
      expect((result as Ok<Video?>).value, isNull);
    });
  });

  group('getWatchProviders', () {
    test('devolve os serviços da região pedida', () async {
      restClient.watchProviders = dunaProvidersResponse;

      final result = await repository.getWatchProviders(dunaId, region: 'BR');

      expect(result, isA<Ok<WatchProviderRegion?>>());
      final region = (result as Ok<WatchProviderRegion?>).value;
      expect(region?.flatrate, [netflix, maxStreaming]);
      expect(region?.link, contains('locale=BR'));
    });

    test('aceita a região em minúsculas', () async {
      restClient.watchProviders = dunaProvidersResponse;

      final result = await repository.getWatchProviders(dunaId, region: 'us');

      expect((result as Ok<WatchProviderRegion?>).value?.flatrate,
          [maxStreaming]);
    });

    test('devolve Ok com null quando a região não aparece na resposta',
        () async {
      restClient.watchProviders = dunaProvidersResponse;

      final result = await repository.getWatchProviders(dunaId, region: 'JP');

      expect(result, isA<Ok<WatchProviderRegion?>>());
      expect((result as Ok<WatchProviderRegion?>).value, isNull);
    });

    test('devolve Ok com null quando a região vem só com o link', () async {
      restClient.watchProviders = dunaProvidersResponse;

      final result = await repository.getWatchProviders(dunaId, region: 'PT');

      expect((result as Ok<WatchProviderRegion?>).value, isNull);
    });

    test('guarda todos os países em cache: trocar de região não refaz a '
        'requisição', () async {
      restClient.watchProviders = dunaProvidersResponse;

      await repository.getWatchProviders(dunaId, region: 'BR');
      final us = await repository.getWatchProviders(dunaId, region: 'US');

      expect(restClient.watchProvidersCallCount, 1);
      expect((us as Ok<WatchProviderRegion?>).value?.flatrate, [maxStreaming]);
    });

    test('devolve Error quando o status HTTP não é de sucesso', () async {
      restClient.statusCode = 500;

      final result = await repository.getWatchProviders(dunaId, region: 'BR');

      expect(result, isA<Error<WatchProviderRegion?>>());
      expect((result as Error<WatchProviderRegion?>).error.toString(),
          contains('500'));
    });

    test('não guarda a falha em cache: a próxima chamada tenta de novo',
        () async {
      restClient.errorToThrow = DioException.connectionError(
        requestOptions: RequestOptions(path: '/movie/watch/providers'),
        reason: 'offline',
      );
      final failed = await repository.getWatchProviders(dunaId, region: 'BR');
      expect(failed, isA<Error<WatchProviderRegion?>>());

      restClient
        ..errorToThrow = null
        ..watchProviders = dunaProvidersResponse;
      final retried = await repository.getWatchProviders(dunaId, region: 'BR');

      expect((retried as Ok<WatchProviderRegion?>).value, isNotNull);
      expect(restClient.watchProvidersCallCount, 2);
    });
  });

  group('idioma do conteúdo', () {
    test('envia o idioma do repositório a todos os endpoints', () async {
      final english = MoviesRepositoryRemote(
        restClient: restClient,
        language: 'en-US',
        preferences: preferences,
      );

      await english.getPopularMovies();
      await english.getMovieDetails(dunaId);
      await english.searchMovies(query: 'duna');
      await english.discoverMovies(genreIds: const [878]);
      await english.getMovieGenres();

      expect(restClient.requestedLanguages, List.filled(5, 'en-US'));
    });

    test('em en-US, não repete a busca de trailer no idioma alternativo',
        () async {
      final english = MoviesRepositoryRemote(
        restClient: restClient,
        language: tmdbFallbackLanguage,
        preferences: preferences,
      );

      final result = await english.getMovieTrailer(matrixId);

      expect(restClient.requestedVideoLanguages, [tmdbFallbackLanguage]);
      expect((result as Ok<Video?>).value, isNull);
    });
  });
}
