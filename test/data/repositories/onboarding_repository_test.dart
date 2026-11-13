import 'package:app_filmes/data/models/user_onboarding_preferences.dart';
import 'package:app_filmes/data/repositories/onboarding_repository.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late OnboardingRepositoryLocal repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );

    repository = OnboardingRepositoryLocal(database: database);
  });

  tearDown(() => database.close());

  test(
    'retorna preferências vazias não concluídas para novo usuário',
    () async {
      final res = await repository.getPreferences('user_123');
      expect(res, isA<Ok>());

      final prefs = (res as Ok).value;
      expect(prefs.userId, 'user_123');
      expect(prefs.isCompleted, isFalse);
      expect(prefs.genres, isEmpty);
    },
  );

  test('salva e recupera preferências de onboarding do usuário', () async {
    final initialPrefs = UserOnboardingPreferences(
      userId: 'user_123',
      genres: ['Ação', 'Animação'],
      actors: ['Keanu Reeves'],
      directors: ['Christopher Nolan'],
      isCompleted: true,
    );

    final saveRes = await repository.savePreferences(initialPrefs);
    expect(saveRes, isA<Ok>());

    final getRes = await repository.getPreferences('user_123');
    expect(getRes, isA<Ok>());

    final saved = (getRes as Ok).value;
    expect(saved.isCompleted, isTrue);
    expect(saved.genres, ['Ação', 'Animação']);
    expect(saved.actors, ['Keanu Reeves']);
    expect(saved.directors, ['Christopher Nolan']);
  });
}
