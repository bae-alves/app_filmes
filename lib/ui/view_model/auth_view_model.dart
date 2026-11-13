import 'package:flutter/foundation.dart';

import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../../utils/result.dart';

/// ViewModel responsável pela gestão do estado de autenticação do usuário.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Carrega a sessão inicial do usuário na inicialização do app.
  Future<void> loadSession() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.getCurrentUser();
    switch (result) {
      case Ok(:final value):
        _currentUser = value;
      case Error(:final error):
        _errorMessage = _cleanError(error);
    }

    _setLoading(false);
  }

  /// Realiza cadastro com e-mail, nome e senha.
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );

    var success = false;
    switch (result) {
      case Ok(:final value):
        _currentUser = value;
        success = true;
      case Error(:final error):
        _errorMessage = _cleanError(error);
    }

    _setLoading(false);
    return success;
  }

  /// Realiza login com e-mail e senha.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    var success = false;
    switch (result) {
      case Ok(:final value):
        _currentUser = value;
        success = true;
      case Error(:final error):
        _errorMessage = _cleanError(error);
    }

    _setLoading(false);
    return success;
  }

  /// Realiza login social (Google ou Apple).
  Future<bool> signInWithSocial({
    required String provider,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.signInWithSocial(
      provider: provider,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );

    var success = false;
    switch (result) {
      case Ok(:final value):
        _currentUser = value;
        success = true;
      case Error(:final error):
        _errorMessage = _cleanError(error);
    }

    _setLoading(false);
    return success;
  }

  /// Atualiza o perfil do usuário logado.
  Future<bool> updateProfile({required String name, String? photoUrl}) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authRepository.updateProfile(
      name: name,
      photoUrl: photoUrl,
    );

    var success = false;
    switch (result) {
      case Ok(:final value):
        _currentUser = value;
        success = true;
      case Error(:final error):
        _errorMessage = _cleanError(error);
    }

    _setLoading(false);
    return success;
  }

  /// Encerra a sessão.
  Future<void> signOut() async {
    _setLoading(true);
    await _authRepository.signOut();
    _currentUser = null;
    _errorMessage = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _cleanError(Object error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.replaceFirst('Exception: ', '');
    }
    if (str.startsWith('StateError: ')) {
      return str.replaceFirst('StateError: ', '');
    }
    if (str.startsWith('ArgumentError: ')) {
      return str.replaceFirst('ArgumentError: ', '');
    }
    return str;
  }
}
