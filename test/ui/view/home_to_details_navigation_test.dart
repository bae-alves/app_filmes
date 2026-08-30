import 'package:app_filmes/data/api_models/movie.dart';
import 'package:app_filmes/ui/view/home_page.dart';
import 'package:app_filmes/ui/view/movie_details_page.dart';
import 'package:app_filmes/ui/view/widgets/movie_card.dart';
import 'package:app_filmes/ui/view_model/home_view_model.dart';
import 'package:app_filmes/ui/view_model/movie_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_movies_repository.dart';
import '../../fakes/movie_fixtures.dart';

/// Comportamento coberto por este arquivo:
///
/// > Dado que estou na tela inicial, quando toco em um cartão de filme, sou
/// > direcionado para uma página com o trailer e as informações do filme.
void main() {
  /// Monta o app com o repositório falso e um player de trailer de mentira.
  ///
  /// O player real depende de uma WebView, que não existe no ambiente de
  /// teste; o stub imprime a chave recebida, o que permite verificar que o
  /// trailer certo chegou à tela.
  Widget buildApp(FakeMoviesRepository repository) {
    return MaterialApp(
      home: HomePage(
        viewModel: HomeViewModel(moviesRepository: repository),
        detailsViewModelFactory: (movieId) => MovieDetailsViewModel(
          moviesRepository: repository,
          movieId: movieId,
        ),
        trailerPlayerBuilder: (context, youtubeKey) =>
            Text('trailer-fake:$youtubeKey'),
      ),
    );
  }

  FakeMoviesRepository buildRepository() => FakeMoviesRepository(
        popularMovies: const [dunaMovie, matrixMovie],
        detailsById: const {dunaId: dunaDetails, matrixId: matrixDetails},
        trailersById: const {dunaId: dunaTrailer},
      );

  testWidgets('a tela inicial lista os filmes populares em cartões',
      (tester) async {
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Filmes populares'), findsOneWidget);
    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('Duna: Parte Dois'), findsOneWidget);
    expect(find.text('Matrix'), findsOneWidget);
  });

  testWidgets(
    'ao tocar em um cartão, abre a página com o trailer e as informações do filme',
    (tester) async {
      final repository = buildRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MovieCard).first);
      await tester.pumpAndSettle();

      // Saímos da tela inicial e chegamos à tela de detalhes.
      expect(find.byType(MovieDetailsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Os detalhes pedidos são os do filme tocado.
      expect(repository.requestedDetailIds, [dunaId]);
      expect(repository.requestedTrailerIds, [dunaId]);

      // O trailer é exibido, com a chave do vídeo do filme selecionado.
      expect(find.byKey(MovieDetailsPage.trailerKey), findsOneWidget);
      expect(find.text('trailer-fake:${dunaTrailer.key}'), findsOneWidget);

      // As informações do filme acompanham o trailer.
      expect(find.text('Duna: Parte Dois'), findsWidgets); // AppBar e título
      expect(find.text('Longa vida aos lutadores.'), findsOneWidget);
      expect(find.text(dunaDetails.overview!), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2h 46min'), findsOneWidget);
      expect(find.text('8,2'), findsOneWidget);
      expect(find.text('Ficção científica'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);
    },
  );

  testWidgets('cada cartão abre a página do seu próprio filme', (tester) async {
    final repository = buildRepository();
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey(matrixId)));
    await tester.pumpAndSettle();

    expect(repository.requestedDetailIds, [matrixId]);
    expect(find.text('Matrix'), findsWidgets);
    expect(find.text('2h 16min'), findsOneWidget);
  });

  testWidgets(
    'filme sem trailer mostra o aviso e mantém as informações',
    (tester) async {
      final repository = buildRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey(matrixId)));
      await tester.pumpAndSettle();

      expect(find.byKey(MovieDetailsPage.trailerKey), findsNothing);
      expect(find.byKey(MovieDetailsPage.emptyTrailerKey), findsOneWidget);
      expect(find.text('Trailer não disponível'), findsOneWidget);
      expect(find.text(matrixDetails.overview!), findsOneWidget);
    },
  );

  testWidgets('é possível voltar da tela de detalhes para a tela inicial',
      (tester) async {
    await tester.pumpWidget(buildApp(buildRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MovieCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(MovieDetailsPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailsPage), findsNothing);
    expect(find.byType(MovieCard), findsNWidgets(2));
  });

  testWidgets('a tela inicial informa quando não há filmes para exibir',
      (tester) async {
    await tester.pumpWidget(buildApp(FakeMoviesRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum filme encontrado no momento.'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('a tela inicial mostra o erro e permite tentar novamente',
      (tester) async {
    final repository = FakeMoviesRepository(
      popularError: Exception('falha de rede'),
    );
    await tester.pumpWidget(buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('falha de rede'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repository.forcedRefreshCount, 1);
  });

  testWidgets('o cartão exibe o filme recebido, sem conhecer o repositório',
      (tester) async {
    Movie? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieCard(
            movie: dunaMovie,
            onTap: () => tapped = dunaMovie,
          ),
        ),
      ),
    );

    expect(find.text('Duna: Parte Dois'), findsOneWidget);
    expect(find.text('8,2'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);

    await tester.tap(find.byType(MovieCard));
    expect(tapped, same(dunaMovie));
  });
}
