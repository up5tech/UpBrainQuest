import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/data/preferences/settings_repository.dart';
import 'package:up_brain_quest/domain/achievements/achievement.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/progress/progress_repository.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';
import 'package:up_brain_quest/features/gameplay/presentation/session_result_page.dart';

/// Returns reduced-motion settings so the result page skips its entrance
/// animation and renders deterministically in tests.
class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository();

  @override
  Future<AppSettings> load() async => const AppSettings(
    reducedMotion: true,
    soundEnabled: true,
    hapticsEnabled: true,
  );
}

/// Records saves and can simulate a persistence failure.
class _FakeHistoryRepository implements SessionHistoryRepository {
  _FakeHistoryRepository({this.fail = false});

  final bool fail;
  int saves = 0;

  @override
  Future<void> saveSession(SessionResult result) async {
    saves++;
    if (fail) throw Exception('save failed');
  }

  @override
  Future<List<SessionSummary>> recentSessions({int limit = 20}) async =>
      <SessionSummary>[];

  @override
  Future<List<String>> recentQuestionIds({int limit = 20}) async => <String>[];

  @override
  Future<ProgressSummary> progressSummary() async =>
      const ProgressSummary.empty();

  @override
  Future<void> clearAll() async {}
}

/// No-op progress persistence so the completion service can run in tests.
class _FakeProgressRepository implements ProgressRepository {
  int dailyRecords = 0;

  @override
  Future<AchievementStats> achievementStats({
    required String todayLocalDate,
  }) async => const AchievementStats.empty();

  @override
  Future<List<AchievementRecord>> loadAchievements() async =>
      <AchievementRecord>[];

  @override
  Future<void> saveAchievements(
    List<AchievementProgress> progress, {
    required DateTime nowUtc,
  }) async {}

  @override
  Future<DailyStatus> dailyStatus(String localDate) async =>
      DailyStatus.none(localDate);

  @override
  Future<void> recordDailyCompletion({
    required String localDate,
    required bool dailyChallenge,
    required DateTime nowUtc,
  }) async {
    dailyRecords++;
  }

  @override
  Future<StreakSummary> streak(String todayLocalDate) async =>
      const StreakSummary.empty();

  @override
  Future<void> clearAll() async {}
}

MultipleChoiceItem _mc({required String id, required String prompt}) =>
    MultipleChoiceItem(
      id: id,
      domain: ContentDomain.iq,
      contentType: ContentType.multipleChoice,
      skill: 'pattern_recognition',
      difficulty: Difficulty.easy,
      locale: 'en',
      prompt: prompt,
      options: const <QuestionOption>[
        QuestionOption(id: 'a', text: 'Alpha'),
        QuestionOption(id: 'b', text: 'Beta'),
      ],
      correctOptionId: 'b',
      explanation: 'Beta is correct.',
      tags: const <String>['test'],
      status: ContentStatus.finalStatus,
    );

EqScenarioItem _eq() => const EqScenarioItem(
  id: 'eq1',
  domain: ContentDomain.eq,
  contentType: ContentType.scenarioChoice,
  skill: 'emotion_awareness',
  difficulty: Difficulty.medium,
  locale: 'en',
  prompt: 'What do you do?',
  scenarioContext: 'A tense meeting.',
  options: <QuestionOption>[
    QuestionOption(id: 'a', text: 'Listen carefully'),
    QuestionOption(id: 'b', text: 'Walk away'),
  ],
  rubricByOption: <String, RubricEntry>{
    'a': RubricEntry(
      scores: <EqDimension, int>{EqDimension.emotionAwareness: 3},
      feedback: 'Listening helps.',
    ),
    'b': RubricEntry(
      scores: <EqDimension, int>{EqDimension.emotionAwareness: 0},
      feedback: 'Walking away may miss context.',
    ),
  },
  tags: <String>['test'],
  status: ContentStatus.finalStatus,
);

/// A mixed Quick Quest result: one wrong MC, one answered EQ, one skipped MC.
SessionResult _mixedResult() {
  final MultipleChoiceItem mc1 = _mc(id: 'mc1', prompt: 'Pick one');
  final MultipleChoiceItem mc2 = _mc(id: 'mc2', prompt: 'Second one');
  final EqScenarioItem eq = _eq();

  const List<PlayerAnswer?> answers = <PlayerAnswer?>[
    SelectedOptionAnswer('a'),
    SelectedOptionAnswer('a'),
    UnansweredAnswer(),
  ];
  final List<AnswerEvaluation?> evaluations = <AnswerEvaluation?>[
    evaluateAnswer(mc1, const SelectedOptionAnswer('a')),
    evaluateAnswer(eq, const SelectedOptionAnswer('a')),
    evaluateAnswer(mc2, const UnansweredAnswer()),
  ];
  final List<AnswerEvaluation> flat = evaluations
      .whereType<AnswerEvaluation>()
      .toList();

  return SessionResult(
    mode: GameMode.quickQuest,
    questions: <QuestionItem>[mc1, eq, mc2],
    answers: answers,
    evaluations: evaluations,
    scoreAlgorithmVersion: 1,
    iqScore: const IqScoreCalculator().calculate(flat),
    eqScore: const EqScoreCalculator().calculate(flat),
    completedAtUtc: DateTime.utc(2026),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  SessionHistoryRepository? history,
  ProgressRepository? progress,
  Size size = const Size(1200, 4000),
  double textScale = 1,
}) async {
  // A tall surface so the lazy ListView builds the review cards too.
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
        sessionHistoryRepositoryProvider.overrideWith(
          (Ref ref) async => history ?? _FakeHistoryRepository(),
        ),
        progressRepositoryProvider.overrideWith(
          (Ref ref) async => progress ?? _FakeProgressRepository(),
        ),
      ],
      child: MaterialApp(home: page),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SessionResultPage', () {
    testWidgets('shows separate IQ/EQ scores and an exact review', (
      WidgetTester tester,
    ) async {
      final _FakeHistoryRepository history = _FakeHistoryRepository();
      await _pump(
        tester,
        SessionResultPage(result: _mixedResult()),
        history: history,
      );

      expect(find.text(AppStrings.sessionIqScoreLabel), findsOneWidget);
      expect(find.text(AppStrings.sessionEqScoreLabel), findsOneWidget);
      expect(find.text(AppStrings.sessionSaved), findsOneWidget);
      expect(history.saves, 1);

      // Review reflects the player's exact recorded responses.
      expect(find.textContaining('Alpha'), findsWidgets);
      expect(
        find.textContaining(AppStrings.sessionCorrectAnswer),
        findsWidgets,
      );
      expect(
        find.textContaining(AppStrings.sessionRubricSummary),
        findsOneWidget,
      );
      expect(
        find.textContaining(AppStrings.eqDimEmotionAwareness),
        findsWidgets,
      );
      expect(find.textContaining('Listening helps.'), findsOneWidget);

      // The skipped question is reported honestly, with an incomplete note.
      expect(
        find.textContaining(AppStrings.sessionNotAnswered),
        findsOneWidget,
      );
      expect(find.text(AppStrings.sessionIncompleteNote), findsOneWidget);
    });

    testWidgets('shows a retryable warning when saving fails', (
      WidgetTester tester,
    ) async {
      final _FakeHistoryRepository history = _FakeHistoryRepository(fail: true);
      await _pump(
        tester,
        SessionResultPage(result: _mixedResult()),
        history: history,
      );

      expect(find.text(AppStrings.sessionSaveFailed), findsOneWidget);
      expect(find.text(AppStrings.sessionSaveRetry), findsOneWidget);
    });

    testWidgets('renders at 2x text scale without overflow', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        SessionResultPage(result: _mixedResult()),
        history: _FakeHistoryRepository(),
        size: const Size(360, 4000),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an empty state without a result', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const SessionResultPage());
      expect(find.text(AppStrings.sessionNotAvailable), findsOneWidget);
    });

    testWidgets('fails closed when the result is inconsistent', (
      WidgetTester tester,
    ) async {
      final SessionResult base = _mixedResult();
      final SessionResult bad = SessionResult(
        mode: base.mode,
        questions: base.questions,
        answers: base.answers.take(1).toList(),
        evaluations: base.evaluations,
        scoreAlgorithmVersion: base.scoreAlgorithmVersion,
        iqScore: base.iqScore,
        eqScore: base.eqScore,
        completedAtUtc: base.completedAtUtc,
      );

      await _pump(tester, SessionResultPage(result: bad));
      expect(find.text(AppStrings.sessionResultError), findsOneWidget);
    });
  });
}
