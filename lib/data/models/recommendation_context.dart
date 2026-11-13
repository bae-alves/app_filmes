class RecommendationContext {
  const RecommendationContext({
    required this.favoriteGenres,
    required this.dislikedGenres,
    required this.recentRatings,
    this.onboardingGenres = const [],
    this.favoriteActors = const [],
    this.favoriteDirectors = const [],
    required this.weekday,
    required this.timeOfDay,
    required this.currentHour,
  });

  final List<String> favoriteGenres;
  final List<String> dislikedGenres;
  final List<String> recentRatings;

  final List<String> onboardingGenres;
  final List<String> favoriteActors;
  final List<String> favoriteDirectors;

  final String weekday;
  final String timeOfDay;
  final int currentHour;

  String toPromptContext() {
    return '''
Preferências do perfil e hábitos do usuário:
- Gêneros favoritos (calculados): ${_formatList(favoriteGenres)}
- Gêneros selecionados no onboarding: ${_formatList(onboardingGenres)}
- Atores favoritos: ${_formatList(favoriteActors)}
- Diretores favoritos: ${_formatList(favoriteDirectors)}
- Gêneros menos apreciados: ${_formatList(dislikedGenres)}
- Avaliações recentes: ${_formatList(recentRatings)}

Contexto temporal:
- Dia da semana: $weekday
- Período: $timeOfDay
- Horário local: ${currentHour.toString().padLeft(2, '0')}h
''';
  }

  String _formatList(List<String> values) {
    return values.isEmpty ? 'Sem informações disponíveis' : values.join(', ');
  }
}
