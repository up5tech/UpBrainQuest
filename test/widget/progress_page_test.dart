import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/features/progress/presentation/progress_page.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Future<ProgressSummary> Function() summary,
  Future<List<SessionSummary>> Function()? history,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        progressSummaryProvider.overrideWith((Ref ref) => summary()),
        sessionHistoryProvider.overrideWith(
          (Ref ref) =>
              history?.call() ??
              Future<List<SessionSummary>>.value(<SessionSummary>[]),
        ),
        achievementsProvider.overrideWith(
          (Ref ref) async => const <AchievementRecord>[],
        ),
        streakProvider.overrideWith(
          (Ref ref) async => const StreakSummary.empty(),
        ),
      ],
      child: const MaterialApp(home: ProgressPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ProgressPage', () {
    testWidgets('shows an honest empty state without history', (
      WidgetTester tester,
    ) async {
      await _pump(tester, summary: () async => const ProgressSummary.empty());
      expect(find.text(AppStrings.progressEmpty), findsOneWidget);
    });

    testWidgets('renders aggregates and recent history from local records', (
      WidgetTester tester,
    ) async {
      const ProgressSummary progress = ProgressSummary(
        sessionCount: 2,
        completedCount: 2,
        modeCounts: <GameMode, int>{GameMode.quickQuest: 2},
        iqBest: 80,
        eqBest: 70,
      );
      final List<SessionSummary> sessions = <SessionSummary>[
        SessionSummary(
          id: 1,
          mode: GameMode.quickQuest,
          completedAtUtc: DateTime.utc(2026),
          questionCount: 10,
          answeredCount: 10,
          iqScore: 80,
          eqScore: 70,
        ),
      ];
      await _pump(
        tester,
        summary: () async => progress,
        history: () async => sessions,
      );

      expect(find.text(AppStrings.progressSessionsCompleted), findsOneWidget);
      expect(find.text(AppStrings.progressBestIq), findsOneWidget);
      expect(find.text(AppStrings.progressBestEq), findsOneWidget);
      expect(find.text(AppStrings.achievementsTitle), findsOneWidget);
      expect(find.text(AppStrings.streakNone), findsOneWidget);
      expect(find.text(AppStrings.progressRecentTitle), findsOneWidget);
      expect(find.text(AppStrings.modeQuickQuest), findsOneWidget);
      expect(find.textContaining('80'), findsWidgets);
    });

    testWidgets('shows a recoverable error state when loading fails', (
      WidgetTester tester,
    ) async {
      await _pump(tester, summary: () async => throw Exception('boom'));
      expect(find.text(AppStrings.progressLoadError), findsOneWidget);
    });
  });
}
