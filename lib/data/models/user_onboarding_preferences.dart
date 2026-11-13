/// Representa as preferências iniciais de gosto do usuário coletadas no onboarding.
class UserOnboardingPreferences {
  const UserOnboardingPreferences({
    required this.userId,
    required this.genres,
    required this.actors,
    required this.directors,
    this.isCompleted = false,
  });

  final String userId;
  final List<String> genres;
  final List<String> actors;
  final List<String> directors;
  final bool isCompleted;

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'genres': genres.join(','),
    'actors': actors.join(','),
    'directors': directors.join(','),
    'is_completed': isCompleted ? 1 : 0,
  };

  factory UserOnboardingPreferences.fromMap(Map<String, dynamic> map) {
    List<String> parseList(String? raw) {
      if (raw == null || raw.trim().isEmpty) return [];
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return UserOnboardingPreferences(
      userId: map['user_id'] as String,
      genres: parseList(map['genres'] as String?),
      actors: parseList(map['actors'] as String?),
      directors: parseList(map['directors'] as String?),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  UserOnboardingPreferences copyWith({
    List<String>? genres,
    List<String>? actors,
    List<String>? directors,
    bool? isCompleted,
  }) {
    return UserOnboardingPreferences(
      userId: userId,
      genres: genres ?? this.genres,
      actors: actors ?? this.actors,
      directors: directors ?? this.directors,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
