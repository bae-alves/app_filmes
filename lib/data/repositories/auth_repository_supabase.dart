import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/result.dart';
import '../models/user_account.dart';
import 'auth_repository.dart';

/// Implementação do [AuthRepository] utilizando o Supabase (`supabase_flutter`).
class AuthRepositorySupabase implements AuthRepository {
  AuthRepositorySupabase({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  UserAccount? _mapUser(User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata;
    final name =
        (metadata?['full_name'] as String?) ??
        (metadata?['name'] as String?) ??
        user.email?.split('@').first ??
        'Usuário';

    final photoUrl =
        (metadata?['avatar_url'] as String?) ??
        (metadata?['picture'] as String?);

    return UserAccount(
      id: user.id,
      name: name,
      email: user.email ?? '',
      authProvider: user.appMetadata['provider'] as String? ?? 'email',
      photoUrl: photoUrl,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  @override
  Future<Result<UserAccount>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      final user = res.user;
      if (user == null) {
        return Result.error(Exception('Não foi possível criar a conta.'));
      }

      return Result.ok(_mapUser(user)!);
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
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        return Result.error(Exception('E-mail ou senha incorretos.'));
      }

      return Result.ok(_mapUser(user)!);
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
      final oAuthProvider = provider.toLowerCase() == 'apple'
          ? OAuthProvider.apple
          : OAuthProvider.google;

      await _client.auth.signInWithOAuth(oAuthProvider);
      final user = _client.auth.currentUser;

      if (user == null) {
        return Result.error(Exception('Falha no login social com $provider.'));
      }

      return Result.ok(_mapUser(user)!);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Result.ok(null);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<UserAccount?>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      return Result.ok(_mapUser(user));
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
      final res = await _client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            if (photoUrl != null) ...{'avatar_url': photoUrl},
          },
        ),
      );

      final user = res.user;
      if (user == null) {
        return Result.error(Exception('Não foi possível atualizar o perfil.'));
      }

      return Result.ok(_mapUser(user)!);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
