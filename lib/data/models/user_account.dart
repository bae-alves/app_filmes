/// Representa uma conta de usuário autenticada no app.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.authProvider,
    this.photoUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;

  /// Provedor de autenticação: 'email', 'google', 'apple'.
  final String authProvider;
  final String? photoUrl;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'auth_provider': authProvider,
    'photo_url': photoUrl,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      authProvider: map['auth_provider'] as String? ?? 'email',
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  UserAccount copyWith({String? name, String? photoUrl}) {
    return UserAccount(
      id: id,
      name: name ?? this.name,
      email: email,
      authProvider: authProvider,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          authProvider == other.authProvider;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ authProvider.hashCode;
}
