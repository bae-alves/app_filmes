import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';

/// Estrutura principal do app: as abas Início, MovieAI, Favoritos e Perfil,
/// com a barra de navegação inferior.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.home,
    required this.assistant,
    required this.favorites,
    this.profile,
  });

  final Widget home;
  final Widget assistant;
  final Widget favorites;
  final Widget? profile;

  /// Índice da aba MovieAI, para [AppShellState.selectTab].
  static const assistantTab = 1;

  /// Estrutura que envolve [context], ou `null` fora dela.
  static AppShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppShellState>();

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _visited = {0};

  /// Mostra a aba [index], como um toque na barra inferior.
  void selectTab(int index) => setState(() {
    _index = index;
    _visited.add(index);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      widget.home,
      widget.assistant,
      widget.favorites,
      if (widget.profile != null) widget.profile!,
    ];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) selectTab(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < tabs.length; i++)
              _visited.contains(i) ? tabs[i] : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(LucideIcons.clapperboard),
              label: l10n.navHome,
            ),
            const NavigationDestination(
              icon: Icon(LucideIcons.sparkles),
              label: 'MovieAI',
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.bookmark),
              label: l10n.favoritesTitle,
            ),
            if (widget.profile != null)
              NavigationDestination(
                icon: const Icon(LucideIcons.user),
                label: l10n.profileTitle,
              ),
          ],
        ),
      ),
    );
  }
}
