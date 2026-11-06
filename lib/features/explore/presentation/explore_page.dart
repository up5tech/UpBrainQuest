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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_ExploreMode> modes = <_ExploreMode>[
      _ExploreMode(
        context.l10n.modeQuickQuest,
        context.l10n.modeQuickQuestDesc,
        Icons.flash_on_outlined,
        '/session/setup/quick',
      ),
      _ExploreMode(
        context.l10n.modeIqChallenge,
        context.l10n.modeIqChallengeDesc,
        Icons.psychology_outlined,
        '/session/setup/iq',
      ),
      _ExploreMode(
        context.l10n.modePuzzleSprint,
        context.l10n.modePuzzleSprintDesc,
        Icons.grid_view_outlined,
        null,
      ),
      _ExploreMode(
        context.l10n.modeEqChallenge,
        context.l10n.modeEqChallengeDesc,
        Icons.favorite_outline,
        '/session/setup/eq',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.exploreTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              context.l10n.exploreSubtitle,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final _ExploreMode mode in modes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ModeCard(
                title: mode.title,
                description: mode.description,
                icon: mode.icon,
                badge: mode.route == null ? context.l10n.comingSoon : null,
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.notAvailableYet)));
  }
}

class _ExploreMode {
  const _ExploreMode(this.title, this.description, this.icon, this.route);

  final String title;
  final String description;
  final IconData icon;
  final String? route;
}
