import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';

/// Estrutura principal do app: as abas Início, MovieAI e Favoritos, com a
/// barra de navegação inferior.
///
/// Recebe as páginas já montadas, para continuar sem conhecer view models nem
/// repositórios. Cada aba só é construída na primeira visita e depois fica
/// viva, guardando rolagem e estado ao trocar de aba.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.home,
    required this.assistant,
    required this.favorites,
  });

  final Widget home;
  final Widget assistant;
  final Widget favorites;

  /// Índice da aba MovieAI, para [AppShellState.selectTab].
  static const assistantTab = 1;

  /// Estrutura que envolve [context], ou `null` fora dela (como nos testes que
  /// montam uma página sozinha).
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
    final tabs = [widget.home, widget.assistant, widget.favorites];

    // Fora do Início, o "voltar" do sistema leva ao Início antes de fechar.
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
          ],
        ),
      ),
    );
  }
}
