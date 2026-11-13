import 'package:app_filmes/data/services/gemini_service.dart';
import 'package:app_filmes/data/services/recommendation_context_service.dart';
import 'package:app_filmes/ui/view_model/chat_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_favorites_repository.dart';
import '../../fakes/fake_movies_repository.dart';
import '../../fakes/fake_ratings_repository.dart';

void main() {
  test(
    'sem a chave da Gemini, o chat mostra o erro em vez de quebrar',
    () async {
      final moviesRepository = FakeMoviesRepository();
      final viewModel = ChatViewModel(
        geminiService: GeminiService(
          apiKey: () => throw StateError('GEMINI_API_KEY ausente'),
        ),
        moviesRepository: moviesRepository,
        recommendationContextService: RecommendationContextService(
          favoritesRepository: FakeFavoritesRepository(),
          ratingsRepository: FakeRatingsRepository(),
          moviesRepository: moviesRepository,
        ),
      );
      addTearDown(viewModel.dispose);

      await viewModel.sendMessage('quero um suspense');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    },
  );
}
