import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/movie_page_response.dart';
import 'package:app_filmes/data/api_models/video.dart';
import 'package:app_filmes/data/api_models/videos_response.dart';
import 'package:app_filmes/data/repositories/movies_repository_remote.dart';
import 'package:app_filmes/data/services/tmdb_rest_client.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_tmdb_rest_client.dart';
import '../../fakes/movie_fixtures.dart';

void main() {
  late FakeTmdbRestClient restClient;
  late MoviesRepositoryRemote repository;

  setUp(() {
    restClient = FakeTmdbRestClient();
    repository = MoviesRepositoryRemote(restClient: restClient);
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

    test('devolve Error quando o serviço falha', () async {
      restClient.errorToThrow = Exception('boom');

      final result = await repository.getMovieDetails(dunaId);

      expect(result, isA<Error<MovieDetails>>());
    });
  });

  group('getMovieTrailer', () {
    test('prefere o trailer oficial do YouTube', () async {
      restClient.videosByLanguage = {
        tmdbDefaultLanguage: const VideosResponse(
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
        tmdbDefaultLanguage: const VideosResponse(
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
        [tmdbDefaultLanguage, tmdbFallbackLanguage],
      );
      expect((result as Ok<Video?>).value?.key, dunaTrailer.key);
    });

    test('não busca o idioma alternativo quando pt-BR já tem vídeo', () async {
      restClient.videosByLanguage = {
        tmdbDefaultLanguage: const VideosResponse(results: [dunaTrailer]),
      };

      await repository.getMovieTrailer(dunaId);

      expect(restClient.requestedVideoLanguages, [tmdbDefaultLanguage]);
    });

    test('devolve Ok com null quando o filme não tem nenhum vídeo', () async {
      final result = await repository.getMovieTrailer(matrixId);

      expect(result, isA<Ok<Video?>>());
      expect((result as Ok<Video?>).value, isNull);
    });
  });
}
