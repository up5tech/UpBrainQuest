import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/history/drift_session_history_repository.dart';
import 'package:up_brain_quest/data/progress/drift_progress_repository.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

MultipleChoiceItem _mc() => const MultipleChoiceItem(
  id: 'q1',
  domain: ContentDomain.iq,
  contentType: ContentType.multipleChoice,
  skill: 'pattern_recognition',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Prompt',
  options: <QuestionOption>[
    QuestionOption(id: 'a', text: 'A'),
    QuestionOption(id: 'b', text: 'B'),
  ],
  correctOptionId: 'a',
  explanation: 'Because.',
  tags: <String>['test'],
  status: ContentStatus.finalStatus,
);

SessionResult _result({
  required GameMode mode,
  required DateTime completedAt,
  int? iqScore,
  int? eqScore,
}) {
  final MultipleChoiceItem mc = _mc();
  return SessionResult(
    mode: mode,
    questions: <QuestionItem>[mc],
    answers: const <PlayerAnswer?>[SelectedOptionAnswer('a')],
    evaluations: <AnswerEvaluation?>[
      evaluateAnswer(mc, const SelectedOptionAnswer('a')),
    ],
    scoreAlgorithmVersion: 1,
    iqScore: iqScore == null
        ? const IqScoreResult.invalid()
        : IqScoreResult(
            valid: true,
            score: iqScore,
            earned: iqScore,
            possible: 100,
          ),
    eqScore: eqScore == null
        ? const EqScoreResult.invalid()
        : EqScoreResult(
            valid: true,
            score: eqScore,
            earned: eqScore,
            possible: 100,
            dimensionEarned: <EqDimension, int>{
              EqDimension.emotionAwareness: eqScore,
            },
            dimensionPossible: <EqDimension, int>{
              EqDimension.emotionAwareness: 100,
            },
          ),
    startedAtUtc: completedAt.subtract(const Duration(minutes: 5)),
    completedAtUtc: completedAt,
  );
}

void main() {
  late AppDatabase database;
  late DriftSessionHistoryRepository history;
  late DriftProgressRepository progress;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    history = DriftSessionHistoryRepository(database);
    progress = DriftProgressRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('a realistic history aggregates correctly and resets cleanly', () async {
    // 10 sessions across 5 consecutive days: 5 IQ, 3 EQ, 2 Quick Quest.
    final List<SessionResult> sessions = <SessionResult>[
      for (int day = 1; day <= 5; day++)
        _result(
          mode: GameMode.iqChallenge,
          completedAt: DateTime.utc(2026, 1, day, 9),
          iqScore: 60 + day * 5,
        ),
      for (int day = 1; day <= 3; day++)
        _result(
          mode: GameMode.eqChallenge,
          completedAt: DateTime.utc(2026, 1, day, 10),
          eqScore: 50 + day * 5,
        ),
      for (int day = 1; day <= 2; day++)
        _result(
          mode: GameMode.quickQuest,
          completedAt: DateTime.utc(2026, 1, day, 11),
          iqScore: 70 + day * 5,
          eqScore: 60 + day * 5,
        ),
    ];
    for (final SessionResult session in sessions) {
      await history.saveSession(session);
    }
    for (int day = 1; day <= 5; day++) {
      await progress.recordDailyCompletion(
        localDate: '2026-01-0$day',
        dailyChallenge: day == 5,
        nowUtc: DateTime.utc(2026, 1, day, 12),
      );
    }

    final ProgressSummary summary = await history.progressSummary();
    expect(summary.sessionCount, 10);
    expect(summary.completedCount, 10);
    expect(summary.iqBest, 85);
    expect(summary.eqBest, 70);

    final AchievementStats stats = await progress.achievementStats(
      todayLocalDate: '2026-01-05',
    );
    expect(stats.completedSessions, 10);
    expect(stats.reasoningSessions, 7);
    expect(stats.reflectionSessions, 5);
    expect(stats.longestStreak, 5);

    await progress.saveAchievements(
      const AchievementEngine().evaluate(stats),
      nowUtc: DateTime.utc(2026, 1, 5, 12),
    );
    final List<AchievementRecord> records = await progress.loadAchievements();
    expect(records.every((AchievementRecord r) => r.unlocked), isTrue);

    final StreakSummary streak = await progress.streak('2026-01-05');
    expect(streak.current, 5);
    expect(streak.longest, 5);

    // Full reset: session history + achievements/daily activity.
    await history.clearAll();
    await progress.clearAll();

    expect(await database.select(database.gameSessions).get(), isEmpty);
    expect(await database.select(database.questionAttempts).get(), isEmpty);
    expect((await history.progressSummary()).sessionCount, 0);
    expect(
      (await progress.loadAchievements()).every(
        (AchievementRecord r) => !r.unlocked,
      ),
      isTrue,
    );
    expect(
      (await progress.dailyStatus('2026-01-05')).completedSessionsCount,
      0,
    );
    expect((await progress.streak('2026-01-05')).current, 0);
  });
}
