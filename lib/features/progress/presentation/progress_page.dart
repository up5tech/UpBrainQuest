import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/core/theme/app_typography.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';
import 'package:up_brain_quest/core/widgets/app_empty_state.dart';
import 'package:up_brain_quest/core/widgets/app_error_state.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';

/// Progress screen backed by actual local records (PLAN Phase 6 task 6/10).
///
/// Shows honest aggregates and a recent-session list; it never fabricates
/// history or implies a standardized measurement (PLAN §4, §14.12).
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProgressSummary> summary = ref.watch(
      progressSummaryProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.progressTitle)),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace? stack) => AppErrorState(
          message: AppStrings.progressLoadError,
          onRetry: () => ref.invalidate(progressSummaryProvider),
        ),
        data: (ProgressSummary data) {
          if (!data.hasHistory) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppEmptyState(
                icon: Icons.bar_chart_outlined,
                message: AppStrings.progressEmpty,
              ),
            );
          }
          return _ProgressBody(summary: data);
        },
      ),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<SessionSummary>> history = ref.watch(
      sessionHistoryProvider,
    );
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        _SummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        _AchievementsSection(
          achievements: ref.watch(achievementsProvider),
          streak: ref.watch(streakProvider),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(AppStrings.progressRecentTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace? stack) => AppErrorState(
            message: AppStrings.progressLoadError,
            onRetry: () => ref.invalidate(sessionHistoryProvider),
          ),
          data: (List<SessionSummary> sessions) => Column(
            children: <Widget>[
              for (final SessionSummary session in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _HistoryTile(session: session),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.progressSessionsCompleted,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            summary.completedCount.toString(),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _ScoreStat(
                  label: AppStrings.progressBestIq,
                  value: summary.iqBest,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ScoreStat(
                  label: AppStrings.progressBestEq,
                  value: summary.eqBest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        Text(value?.toString() ?? '—', style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({
    required this.achievements,
    required this.streak,
  });

  final AsyncValue<List<AchievementRecord>> achievements;
  final AsyncValue<StreakSummary> streak;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int streakDays = streak.value?.current ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.achievementsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          streakDays > 0
              ? '$streakDays ${AppStrings.streakDaySuffix}'
              : AppStrings.streakNone,
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xxs),
        const Text(
          AppStrings.streakLocalNote,
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        achievements.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace? stack) => const Text(
            AppStrings.achievementsLoadError,
            style: AppTypography.bodySecondary,
          ),
          data: (List<AchievementRecord> records) => Column(
            children: <Widget>[
              for (final AchievementRecord record in records)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AchievementTile(record: record),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.record});

  final AchievementRecord record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return MergeSemantics(
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              record.unlocked ? Icons.emoji_events : Icons.lock_outline,
              color: record.unlocked
                  ? AppColors.positive
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppStrings.achievementTitle(record.id),
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    AppStrings.achievementDescription(record.id),
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppStrings.fractionOf(record.current, record.target),
                    style: AppTypography.bodySecondary,
                  ),
                  if (record.unlocked)
                    const Text(
                      AppStrings.achievementUnlocked,
                      style: AppTypography.bodySecondary,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.session});

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String when = DateFormat.yMMMd().add_Hm().format(
      session.completedAtUtc.toLocal(),
    );
    final List<String> scores = <String>[
      if (session.iqScore != null)
        '${AppStrings.sessionIqScoreLabel}: ${session.iqScore}',
      if (session.eqScore != null)
        '${AppStrings.sessionEqScoreLabel}: ${session.eqScore}',
    ];
    final String progress = AppStrings.fractionOf(
      session.answeredCount,
      session.questionCount,
    );
    final String scoreSummary = scores.isEmpty ? '—' : scores.join(' · ');
    return MergeSemantics(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.gameModeLabel(session.mode),
              style: theme.textTheme.titleLarge,
            ),
            Text(when, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$progress · $scoreSummary',
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
