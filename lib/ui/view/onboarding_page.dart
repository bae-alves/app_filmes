import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../view_model/onboarding_view_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.viewModel,
    required this.onCompleted,
  });

  final OnboardingViewModel viewModel;
  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Future<void> _handleFinish() async {
    final success = await widget.viewModel.saveAndComplete();
    if (success && mounted) {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final step = vm.currentStep;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(l10n.onboardingTitle),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6),
              child: LinearProgressIndicator(
                value: (step + 1) / 3,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: step,
                    children: [
                      _buildGenresStep(theme, vm, l10n),
                      _buildActorsStep(theme, vm, l10n),
                      _buildDirectorsStep(theme, vm, l10n),
                    ],
                  ),
                ),
                _buildBottomBar(theme, vm, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenresStep(
    ThemeData theme,
    OnboardingViewModel vm,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.film,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.onboardingStepLabel(1, 3),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingGenresTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingGenresSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final genre in OnboardingViewModel.popularGenres)
                FilterChip(
                  label: Text(genre),
                  selected: vm.selectedGenres.contains(genre),
                  onSelected: (_) => vm.toggleGenre(genre),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  showCheckmark: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActorsStep(
    ThemeData theme,
    OnboardingViewModel vm,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.user,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.onboardingStepLabel(2, 3),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingActorsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingActorsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: OnboardingViewModel.popularActors.length,
            itemBuilder: (context, index) {
              final actor = OnboardingViewModel.popularActors[index];
              final isSelected = vm.selectedActors.contains(actor.name);

              return GestureDetector(
                onTap: () => vm.toggleActor(actor.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(actor.imageUrl),
                        backgroundColor: theme.colorScheme.surface,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        actor.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (actor.knownFor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          actor.knownFor!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorsStep(
    ThemeData theme,
    OnboardingViewModel vm,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.clapperboard,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.onboardingStepLabel(3, 3),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingDirectorsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingDirectorsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: OnboardingViewModel.popularDirectors.length,
            itemBuilder: (context, index) {
              final director = OnboardingViewModel.popularDirectors[index];
              final isSelected = vm.selectedDirectors.contains(director.name);

              return GestureDetector(
                onTap: () => vm.toggleDirector(director.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(director.imageUrl),
                        backgroundColor: theme.colorScheme.surface,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        director.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (director.knownFor != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          director.knownFor!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    ThemeData theme,
    OnboardingViewModel vm,
    AppLocalizations l10n,
  ) {
    final isLastStep = vm.currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (vm.currentStep > 0)
            OutlinedButton(
              onPressed: vm.previousStep,
              child: Text(l10n.btnBack),
            )
          else
            TextButton(onPressed: _handleFinish, child: Text(l10n.btnSkip)),
          const Spacer(),
          FilledButton.icon(
            onPressed: vm.isLoading
                ? null
                : (isLastStep ? _handleFinish : vm.nextStep),
            icon: vm.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isLastStep ? LucideIcons.check : LucideIcons.arrowRight),
            label: Text(isLastStep ? l10n.btnFinish : l10n.btnNext),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
