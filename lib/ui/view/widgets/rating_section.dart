import 'package:flutter/material.dart';

import '../../../data/repositories/ratings_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../view_model/movie_rating_view_model.dart';

/// Seção "Sua avaliação" da tela de detalhes: cinco estrelas e as reações de
/// humor. Tocar na nota ou na reação marcada a desmarca.
class RatingSection extends StatelessWidget {
  const RatingSection({super.key, required this.viewModel});

  final MovieRatingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final stars = viewModel.stars ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ratingTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.ratingHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var n = 1; n <= 5; n++)
                  IconButton(
                    isSelected: n <= stars,
                    icon: const Icon(Icons.star_border_rounded),
                    selectedIcon: Icon(
                      Icons.star_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: l10n.ratingStars(n),
                    onPressed: () => viewModel.setStars(n),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final mood in Mood.values)
                  ChoiceChip(
                    // Sem o visto, que tomaria o lugar do emoji.
                    showCheckmark: false,
                    avatar: Text(_emoji(mood)),
                    label: Text(_label(mood, l10n)),
                    selected: viewModel.mood == mood,
                    onSelected: (_) => viewModel.setMood(mood),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _emoji(Mood mood) => switch (mood) {
    Mood.loved => '😍',
    Mood.funny => '😂',
    Mood.moved => '😢',
    Mood.tense => '😱',
    Mood.bored => '😴',
  };

  static String _label(Mood mood, AppLocalizations l10n) => switch (mood) {
    Mood.loved => l10n.moodLoved,
    Mood.funny => l10n.moodFunny,
    Mood.moved => l10n.moodMoved,
    Mood.tense => l10n.moodTense,
    Mood.bored => l10n.moodBored,
  };
}
