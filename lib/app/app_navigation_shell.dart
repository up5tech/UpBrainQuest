import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';

/// Persistent bottom-navigation shell shared by the four main destinations.
///
/// The active game session is intentionally excluded from this shell
/// (PLAN §2.1, Phase 1 task 3). Built with [StatefulShellRoute.indexedStack]
/// so each branch keeps its own state while the bar stays mounted.
class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Grow the bar with the text scale so large accessibility text does not
    // overflow the fixed Material height (PLAN Phase 8 acceptance).
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 80 * (textScale < 1 ? 1 : textScale),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: context.l10n.navExplore,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: context.l10n.navProgress,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
