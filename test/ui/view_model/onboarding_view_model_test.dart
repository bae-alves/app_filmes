import 'package:app_filmes/data/repositories/onboarding_repository.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/ui/view_model/onboarding_view_model.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late OnboardingRepositoryLocal repository;
  late OnboardingViewModel viewModel;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );

    repository = OnboardingRepositoryLocal(database: database);
    viewModel = OnboardingViewModel(
      onboardingRepository: repository,
      userId: 'user_test',
    );
  });

  tearDown(() {
    viewModel.dispose();
    database.close();
  });

  test('inicia na etapa 0 (Gêneros) e sem seleções', () {
    expect(viewModel.currentStep, equals(0));
    expect(viewModel.selectedGenres, isEmpty);
    expect(viewModel.selectedActors, isEmpty);
    expect(viewModel.selectedDirectors, isEmpty);
  });

  test('permite selecionar e alternar gêneros, atores e diretores', () {
    viewModel.toggleGenre('Ação');
    expect(viewModel.selectedGenres, contains('Ação'));

    viewModel.toggleGenre('Ação');
    expect(viewModel.selectedGenres, isNot(contains('Ação')));

    viewModel.toggleActor('Keanu Reeves');
    expect(viewModel.selectedActors, contains('Keanu Reeves'));

    viewModel.toggleDirector('Christopher Nolan');
    expect(viewModel.selectedDirectors, contains('Christopher Nolan'));
  });

  test('avançar e voltar etapas', () {
    expect(viewModel.currentStep, equals(0));

    viewModel.nextStep();
    expect(viewModel.currentStep, equals(1));

    viewModel.nextStep();
    expect(viewModel.currentStep, equals(2));

    viewModel.previousStep();
    expect(viewModel.currentStep, equals(1));
  });

  test(
    'saveAndComplete persiste preferências e conclui o onboarding',
    () async {
      viewModel.toggleGenre('Comédia');
      viewModel.toggleActor('Zendaya');
      viewModel.toggleDirector('Denis Villeneuve');

      final success = await viewModel.saveAndComplete();
      expect(success, isTrue);

      final res = await repository.getPreferences('user_test');
      if (res case Ok(:final value)) {
        expect(value.isCompleted, isTrue);
        expect(value.genres, equals(['Comédia']));
        expect(value.actors, equals(['Zendaya']));
        expect(value.directors, equals(['Denis Villeneuve']));
      } else {
        fail('Esperado Ok');
      }
    },
  );
}
