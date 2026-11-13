import '../models/user_account.dart';
import '../../utils/result.dart';

/// Contrato para gestão de autenticação e conta de usuário.
///
/// Permite alternar entre implementações (ex.: [AuthRepositoryLocal],
/// Firebase ou Supabase) sem impactar as demais camadas da aplicação.
abstract interface class AuthRepository {
  /// Registra uma nova conta com e-mail, senha e nome.
  Future<Result<UserAccount>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Realiza o login com e-mail e senha.
  Future<Result<UserAccount>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Realiza o login social (Google ou Apple).
  Future<Result<UserAccount>> signInWithSocial({
    required String provider, // 'google' ou 'apple'
    required String email,
    required String name,
    String? photoUrl,
  });

  /// Encerra a sessão do usuário atualmente logado.
  Future<Result<void>> signOut();

  /// Recupera o usuário atualmente autenticado (se houver sessão ativa).
  Future<Result<UserAccount?>> getCurrentUser();

  /// Atualiza as informações de perfil do usuário.
  Future<Result<UserAccount>> updateProfile({
    required String name,
    String? photoUrl,
  });
}
