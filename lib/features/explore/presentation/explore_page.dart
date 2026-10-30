import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/widgets/mode_card.dart';

/// Explore screen (PLAN §8.3).
///
/// Difficulty and length selectors arrive in a later phase. Quick Quest
/// (Phase 5), IQ Challenge (Phase 3) and EQ Challenge (Phase 4) are playable,
/// so their cards launch the setup flow; the others stay honest "Coming soon"
/// entries rather than faking a session (PLAN §14.12).
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const List<_ExploreMode> _modes = <_ExploreMode>[
    _ExploreMode(
      AppStrings.modeQuickQuest,
      AppStrings.modeQuickQuestDesc,
      Icons.flash_on_outlined,
      '/session/setup/quick',
    ),
    _ExploreMode(
      AppStrings.modeIqChallenge,
      AppStrings.modeIqChallengeDesc,
      Icons.psychology_outlined,
      '/session/setup/iq',
    ),
    _ExploreMode(
      AppStrings.modePuzzleSprint,
      AppStrings.modePuzzleSprintDesc,
      Icons.grid_view_outlined,
      null,
    ),
    _ExploreMode(
      AppStrings.modeEqChallenge,
      AppStrings.modeEqChallengeDesc,
      Icons.favorite_outline,
      '/session/setup/eq',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exploreTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              AppStrings.exploreSubtitle,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final _ExploreMode mode in _modes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ModeCard(
                title: mode.title,
                description: mode.description,
                icon: mode.icon,
                badge: mode.route == null ? AppStrings.comingSoon : null,
                onTap: mode.route == null
                    ? () => _notify(context)
                    : () => context.go(mode.route!),
              ),
            ),
        ],
      ),
    );
  }

  void _notify(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.notAvailableYet)));
  }
}

class _ExploreMode {
  const _ExploreMode(this.title, this.description, this.icon, this.route);

  final String title;
  final String description;
  final IconData icon;
  final String? route;
}
