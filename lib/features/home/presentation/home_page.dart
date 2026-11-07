import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_gradients.dart';
import 'package:up_brain_quest/core/theme/app_radii.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_button.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';
import 'package:up_brain_quest/core/widgets/app_empty_state.dart';
import 'package:up_brain_quest/core/widgets/mode_card.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';

/// Home screen (PLAN §8.3).
///
/// The hero CTA starts a Quick Quest (PLAN §8.3: main CTA "Start Quick Quest").
/// IQ Challenge (Phase 3), EQ Challenge (Phase 4) and Quick Quest (Phase 5) are
/// playable; the remaining modes are honestly shown as "Coming soon"
/// (PLAN §14.12).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final List<_ModeEntry> modes = <_ModeEntry>[
      _ModeEntry(
        context.l10n.modeQuickQuest,
        context.l10n.modeQuickQuestDesc,
        Icons.flash_on_outlined,
        '/session/setup/quick',
      ),
      _ModeEntry(
        context.l10n.modeIqChallenge,
        context.l10n.modeIqChallengeDesc,
        Icons.psychology_outlined,
        '/session/setup/iq',
      ),
      _ModeEntry(
        context.l10n.modePuzzleSprint,
        context.l10n.modePuzzleSprintDesc,
        Icons.grid_view_outlined,
        null,
      ),
      _ModeEntry(
        context.l10n.modeEqChallenge,
        context.l10n.modeEqChallengeDesc,
        Icons.favorite_outline,
        '/session/setup/eq',
      ),
    ];
    final AsyncValue<DailyStatus> daily = ref.watch(dailyStatusProvider);
    final bool dailyDone = daily.value?.completedDailyChallenge ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          _HeroCard(onStart: () => context.go('/session/setup/quick')),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.homeProgressSummary,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HomeProgress(summary: ref.watch(progressSummaryProvider)),
          const SizedBox(height: AppSpacing.md),
          _HomeAchievements(
            achievements: ref.watch(achievementsProvider),
            streak: ref.watch(streakProvider),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...modes.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ModeCard(
                title: entry.title,
                description: entry.description,
                icon: entry.icon,
                badge: entry.route == null ? context.l10n.comingSoon : null,
                onTap: entry.route == null
                    ? () => _showNotReady(context)
                    : () => context.go(entry.route!),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ModeCard(
              title: context.l10n.modeDailyChallenge,
              description: context.l10n.modeDailyChallengeDesc,
              icon: Icons.calendar_today_outlined,
              badge: dailyDone ? context.l10n.dailyDoneToday : null,
              onTap: () => context.go('/session/setup/daily'),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotReady(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.notAvailableYet)));
  }
}

/// Compact, honest progress preview on Home (PLAN Phase 6 task 10).
class _HomeProgress extends StatelessWidget {
  const _HomeProgress({required this.summary});

  final AsyncValue<ProgressSummary> summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return summary.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace? stack) =>
          AppEmptyState(message: context.l10n.homeProgressError),
      data: (ProgressSummary data) {
        if (!data.hasHistory) {
          return AppEmptyState(message: context.l10n.homeNoProgress);
        }
        final List<String> bests = <String>[
          if (data.iqBest != null)
            '${context.l10n.progressBestIq}: ${data.iqBest}',
          if (data.eqBest != null)
            '${context.l10n.progressBestEq}: ${data.eqBest}',
        ];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.completedCount.toString(),
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                context.l10n.progressSessionsCompleted,
                style: AppTypography.bodySecondary,
              ),
              if (bests.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(bests.join(' · '), style: AppTypography.bodySecondary),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Compact achievement + streak preview on Home (PLAN §8.3, Phase 7).
class _HomeAchievements extends StatelessWidget {
  const _HomeAchievements({required this.achievements, required this.streak});

  final AsyncValue<List<AchievementRecord>> achievements;
  final AsyncValue<StreakSummary> streak;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<AchievementRecord> records =
        achievements.value ?? const <AchievementRecord>[];
    final int unlocked = records
        .where((AchievementRecord record) => record.unlocked)
        .length;
    final int total = records.isEmpty
        ? AchievementCatalog.all.length
        : records.length;
    AchievementRecord? next;
    for (final AchievementRecord record in records) {
      if (!record.unlocked) {
        next = record;
        break;
      }
    }
    final int streakDays = streak.value?.current ?? 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.l10n.achievementsTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text('$unlocked / $total', style: AppTypography.bodySecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (next != null)
            Text(
              '${context.l10n.achievementTitle(next.id)} · '
              '${next.current}/${next.target}',
              style: AppTypography.bodySecondary,
            ),
          Text(
            streakDays > 0
                ? '$streakDays ${context.l10n.streakDaySuffix}'
                : context.l10n.streakNone,
            style: AppTypography.bodySecondary,
          ),
          Text(
            context.l10n.streakLocalNote,
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _ModeEntry {
  const _ModeEntry(this.title, this.description, this.icon, this.route);

  final String title;
  final String description;
  final IconData icon;
  final String? route;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The hero sits on the violet gradient, so its copy uses the dark
          // on-accent colour; the light page text only reaches 2-4:1 there.
          Text(
            context.l10n.appName,
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColors.textOnAccent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.homeGreeting,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textOnAccent,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: context.l10n.homeStartQuickQuest,
              onPressed: onStart,
            ),
          ),
        ],
      ),
    );
  }
}
