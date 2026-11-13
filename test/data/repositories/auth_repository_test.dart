import 'package:app_filmes/data/repositories/auth_repository_local.dart';
import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SharedPreferences preferences;
  late AuthRepositoryLocal repository;

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
  });

  tearDown(() => database.close());

  test('começa sem usuário logado', () async {
    final result = await repository.getCurrentUser();
    expect(result, isA<Ok>());
    expect((result as Ok).value, isNull);
  });

  test('cadastra usuário com e-mail e senha e persiste a sessão', () async {
    final signUpResult = await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );

    expect(signUpResult, isA<Ok>());
    final user = (signUpResult as Ok).value;
    expect(user.name, 'Maria Silva');
    expect(user.email, 'maria@email.com');
    expect(user.authProvider, 'email');

    final currentUserResult = await repository.getCurrentUser();
    expect(currentUserResult, isA<Ok>());
    expect((currentUserResult as Ok).value, user);
  });

  test('impede cadastro com e-mail duplicado', () async {
    await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senha123',
    );

    final duplicateResult = await repository.signUpWithEmail(
      name: 'Maria Outra',
      email: 'maria@email.com',
      password: 'outraSenha123',
    );

    expect(duplicateResult, isA<Error>());
  });

  test('realiza login por e-mail e senha com sucesso', () async {
    await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );
    await repository.signOut();

    final signInResult = await repository.signInWithEmail(
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );

    expect(signInResult, isA<Ok>());
    expect((signInResult as Ok).value.email, 'maria@email.com');
  });

  test('falha ao tentar login com senha incorreta', () async {
    await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );
    await repository.signOut();

    final signInResult = await repository.signInWithEmail(
      email: 'maria@email.com',
      password: 'senhaErrada',
    );

    expect(signInResult, isA<Error>());
  });

  test(
    'realiza login social (Google) criando nova conta se necessário',
    () async {
      final socialResult = await repository.signInWithSocial(
        provider: 'google',
        email: 'joao.google@gmail.com',
        name: 'João Google',
        photoUrl: 'https://photo.url/joao.png',
      );

      expect(socialResult, isA<Ok>());
      final user = (socialResult as Ok).value;
      expect(user.name, 'João Google');
      expect(user.authProvider, 'google');

      final currentUserResult = await repository.getCurrentUser();
      expect((currentUserResult as Ok).value, user);
    },
  );

  test('atualiza perfil do usuário', () async {
    await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );

    final updateResult = await repository.updateProfile(name: 'Maria de Souza');

    expect(updateResult, isA<Ok>());
    expect((updateResult as Ok).value.name, 'Maria de Souza');
  });

  test('encerra a sessão com signOut', () async {
    await repository.signUpWithEmail(
      name: 'Maria Silva',
      email: 'maria@email.com',
      password: 'senhaSegura123',
    );

    await repository.signOut();

    final currentUserResult = await repository.getCurrentUser();
    expect((currentUserResult as Ok).value, isNull);
  });
}
