import 'package:app_filmes/data/api_models/genre.dart';
import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/data/api_models/movie_details.dart';
import 'package:app_filmes/data/api_models/video.dart';
import 'package:app_filmes/data/api_models/watch_providers.dart';

/// Massa de dados compartilhada entre os testes.
///
/// Os valores imitam o formato real do TMDB (inclusive campos ausentes) para
/// que os testes exercitem os mesmos caminhos do app em produção.

const dunaId = 693134;
const matrixId = 603;

const dunaMovie = Movie(
  id: dunaId,
  title: 'Duna: Parte Dois',
  originalTitle: 'Dune: Part Two',
  overview: 'Paul Atreides se une aos Fremen para vingar sua família.',
  posterPath: '/duna.jpg',
  backdropPath: '/duna-backdrop.jpg',
  releaseDate: '2024-02-27',
  voteAverage: 8.2,
  voteCount: 5000,
);

const matrixMovie = Movie(
  id: matrixId,
  title: 'Matrix',
  originalTitle: 'The Matrix',
  overview: 'Um programador descobre a verdade sobre a realidade.',
  posterPath: '/matrix.jpg',
  releaseDate: '1999-03-30',
  voteAverage: 8.7,
  voteCount: 24000,
);

const dunaDetails = MovieDetails(
  id: dunaId,
  title: 'Duna: Parte Dois',
  originalTitle: 'Dune: Part Two',
  tagline: 'Longa vida aos lutadores.',
  overview: 'Paul Atreides se une aos Fremen para vingar sua família.',
  posterPath: '/duna.jpg',
  backdropPath: '/duna-backdrop.jpg',
  releaseDate: '2024-02-27',
  runtime: 166,
  voteAverage: 8.2,
  voteCount: 5000,
  genres: [
    Genre(id: 878, name: 'Ficção científica'),
    Genre(id: 12, name: 'Aventura'),
  ],
);

/// Filme sem trailer e sem alguns campos opcionais.
const matrixDetails = MovieDetails(
  id: matrixId,
  title: 'Matrix',
  originalTitle: 'The Matrix',
  overview: 'Um programador descobre a verdade sobre a realidade.',
  posterPath: '/matrix.jpg',
  releaseDate: '1999-03-30',
  runtime: 136,
  voteAverage: 8.7,
);

const dunaTrailer = Video(
  id: 'v1',
  name: 'Trailer Oficial Dublado',
  key: 'Way9Dexny3w',
  site: 'YouTube',
  size: 1080,
  type: 'Trailer',
  official: true,
  publishedAt: '2024-01-10T13:00:00.000Z',
);

const netflix = WatchProvider(
  providerId: 8,
  providerName: 'Netflix',
  logoPath: '/netflix.jpg',
  displayPriority: 5,
);

const maxStreaming = WatchProvider(
  providerId: 1899,
  providerName: 'Max',
  logoPath: '/max.jpg',
  displayPriority: 1,
);

const appleTv = WatchProvider(
  providerId: 2,
  providerName: 'Apple TV',
  logoPath: '/apple.jpg',
  displayPriority: 3,
);

/// Onde assistir Duna no Brasil: duas assinaturas (fora de ordem de
/// prioridade, de propósito) e o mesmo serviço para alugar e comprar.
const dunaProvidersBr = WatchProviderRegion(
  link: 'https://www.themoviedb.org/movie/693134/watch?locale=BR',
  flatrate: [netflix, maxStreaming],
  rent: [appleTv],
  buy: [appleTv],
);

/// Onde assistir Duna nos EUA: só uma assinatura.
const dunaProvidersUs = WatchProviderRegion(
  link: 'https://www.themoviedb.org/movie/693134/watch?locale=US',
  flatrate: [maxStreaming],
);

/// Resposta do TMDB para Duna: BR e US com serviços, e PT presente mas vazio
/// (o TMDB às vezes devolve o país só com o link).
const dunaProvidersResponse = WatchProvidersResponse(
  id: dunaId,
  results: {
    'BR': dunaProvidersBr,
    'US': dunaProvidersUs,
    'PT': WatchProviderRegion(link: 'https://www.themoviedb.org/movie/693134/watch?locale=PT'),
  },
);
