import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_account.dart';
import '../services/app_database.dart';
import '../../utils/result.dart';
import 'auth_repository.dart';

/// Implementação local do [AuthRepository] que persiste contas no SQLite
/// ([AppDatabase.usersTable]) e a sessão no [SharedPreferences].
class AuthRepositoryLocal implements AuthRepository {
  AuthRepositoryLocal({
    required Database database,
    required SharedPreferences preferences,
  }) : _db = database,
       _prefs = preferences;

  final Database _db;
  final SharedPreferences _prefs;

  static const _currentUserIdKey = 'auth_current_user_id';

  String _hashPassword(String password) {
    final bytes = utf8.encode('app_filmes_salt_$password');
    return base64Encode(bytes);
  }

  @override
  Future<Result<UserAccount>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanName = name.trim();

      if (cleanEmail.isEmpty || cleanName.isEmpty || password.isEmpty) {
        return Result.error(
          Exception('Preencha todos os campos obrigatórios.'),
        );
      }

      final existing = await _db.query(
        AppDatabase.usersTable,
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      if (existing.isNotEmpty) {
        return Result.error(Exception('Este e-mail já está cadastrado.'));
      }

      final now = DateTime.now();
      final id = 'user_${now.millisecondsSinceEpoch}';
      final account = UserAccount(
        id: id,
        name: cleanName,
        email: cleanEmail,
        authProvider: 'email',
        createdAt: now,
      );

      await _db.insert(AppDatabase.usersTable, {
        ...account.toMap(),
        'password_hash': _hashPassword(password),
      });

      await _prefs.setString(_currentUserIdKey, id);
      return Result.ok(account);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserAccount>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final hash = _hashPassword(password);

      final result = await _db.query(
        AppDatabase.usersTable,
        where: 'email = ? AND password_hash = ?',
        whereArgs: [cleanEmail, hash],
      );

      if (result.isEmpty) {
        return Result.error(Exception('E-mail ou senha incorretos.'));
      }

      final account = UserAccount.fromMap(result.first);
      await _prefs.setString(_currentUserIdKey, account.id);
      return Result.ok(account);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserAccount>> signInWithSocial({
    required String provider,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanName = name.trim();

      final existing = await _db.query(
        AppDatabase.usersTable,
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      UserAccount account;

      if (existing.isNotEmpty) {
        account = UserAccount.fromMap(
          existing.first,
        ).copyWith(name: cleanName, photoUrl: photoUrl);
        await _db.update(
          AppDatabase.usersTable,
          account.toMap(),
          where: 'id = ?',
          whereArgs: [account.id],
        );
      } else {
        final now = DateTime.now();
        account = UserAccount(
          id: '${provider}_${now.millisecondsSinceEpoch}',
          name: cleanName,
          email: cleanEmail,
          authProvider: provider,
          photoUrl: photoUrl,
          createdAt: now,
        );

        await _db.insert(AppDatabase.usersTable, account.toMap());
      }

      await _prefs.setString(_currentUserIdKey, account.id);
      return Result.ok(account);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _prefs.remove(_currentUserIdKey);
      return const Result.ok(null);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserAccount?>> getCurrentUser() async {
    try {
      final id = _prefs.getString(_currentUserIdKey);
      if (id == null) return const Result.ok(null);

      final result = await _db.query(
        AppDatabase.usersTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        await _prefs.remove(_currentUserIdKey);
        return const Result.ok(null);
      }

      return Result.ok(UserAccount.fromMap(result.first));
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserAccount>> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      final userResult = await getCurrentUser();
      final user = switch (userResult) {
        Ok(:final value) => value,
        Error(:final error) => throw error,
      };

      if (user == null) {
        return Result.error(Exception('Nenhum usuário autenticado.'));
      }

      final updated = user.copyWith(name: name.trim(), photoUrl: photoUrl);
      await _db.update(
        AppDatabase.usersTable,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );

      return Result.ok(updated);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
