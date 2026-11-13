class RecommendationContext {
  const RecommendationContext({
    required this.favoriteGenres,
    required this.dislikedGenres,
    required this.recentRatings,
    required this.weekday,
    required this.timeOfDay,
    required this.currentHour,
  });

  final List<String> favoriteGenres;
  final List<String> dislikedGenres;
  final List<String> recentRatings;

  final String weekday;
  final String timeOfDay;
  final int currentHour;

  String toPromptContext() {
    return '''
Preferências do usuário:
- Gêneros favoritos: ${_formatList(favoriteGenres)}
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
