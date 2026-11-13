import 'package:app_filmes/data/repositories/auth_repository_local.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/ui/view_model/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SharedPreferences preferences;
  late AuthRepositoryLocal repository;
  late AuthViewModel viewModel;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );

    repository = AuthRepositoryLocal(
      database: database,
      preferences: preferences,
    );

    viewModel = AuthViewModel(authRepository: repository);
  });

  tearDown(() {
    viewModel.dispose();
    database.close();
  });

  test('inicialmente não autenticado', () async {
    await viewModel.loadSession();
    expect(viewModel.isAuthenticated, isFalse);
    expect(viewModel.currentUser, isNull);
  });

  test('cadastra usuário e notifica listeners', () async {
    var notified = false;
    viewModel.addListener(() => notified = true);

    final success = await viewModel.signUpWithEmail(
      name: 'Carlos',
      email: 'carlos@email.com',
      password: '123456password',
    );

    expect(success, isTrue);
    expect(notified, isTrue);
    expect(viewModel.isAuthenticated, isTrue);
    expect(viewModel.currentUser?.name, 'Carlos');
  });

  test(
    'define mensagem de erro ao tentar cadastrar e-mail inválido/existente',
    () async {
      await viewModel.signUpWithEmail(
        name: 'Carlos',
        email: 'carlos@email.com',
        password: '123456password',
      );

      final duplicateSuccess = await viewModel.signUpWithEmail(
        name: 'Outro Carlos',
        email: 'carlos@email.com',
        password: 'outrasenha',
      );

      expect(duplicateSuccess, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    },
  );
}
