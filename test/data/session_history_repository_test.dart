import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/data/history/drift_session_history_repository.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

MultipleChoiceItem _mc(String id) => MultipleChoiceItem(
  id: id,
  domain: ContentDomain.iq,
  contentType: ContentType.multipleChoice,
  skill: 'pattern_recognition',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Prompt $id',
  options: const <QuestionOption>[
    QuestionOption(id: 'a', text: 'A'),
    QuestionOption(id: 'b', text: 'B'),
  ],
  correctOptionId: 'a',
  explanation: 'Because.',
  tags: const <String>['test'],
  status: ContentStatus.finalStatus,
);

SessionResult _result({
  int count = 2,
  String? duplicateId,
  DateTime? completedAt,
}) {
  final List<QuestionItem> questions = <QuestionItem>[
    for (int i = 0; i < count; i++) _mc(duplicateId ?? 'q$i'),
  ];
  final List<PlayerAnswer?> answers = <PlayerAnswer?>[
    for (int i = 0; i < count; i++) const SelectedOptionAnswer('a'),
  ];
  final List<AnswerEvaluation?> evaluations = <AnswerEvaluation?>[
    for (int i = 0; i < count; i++)
      evaluateAnswer(questions[i], const SelectedOptionAnswer('a')),
  ];
  final List<AnswerEvaluation> flat = evaluations
      .whereType<AnswerEvaluation>()
      .toList();
  final DateTime completed = completedAt ?? DateTime.utc(2026);
  return SessionResult(
    mode: GameMode.iqChallenge,
    questions: questions,
    answers: answers,
    evaluations: evaluations,
    scoreAlgorithmVersion: 1,
    iqScore: const IqScoreCalculator().calculate(flat),
    eqScore: const EqScoreCalculator().calculate(flat),
    startedAtUtc: completed.subtract(const Duration(minutes: 3)),
    contentPackVersion: 'test',
    completedAtUtc: completed,
  );
}

void main() {
  late AppDatabase database;
  late DriftSessionHistoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftSessionHistoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saveSession writes one session and one attempt per question', () async {
    await repository.saveSession(_result(count: 3));

    final List<GameSession> sessions = await database
        .select(database.gameSessions)
        .get();
    expect(sessions.length, 1);
    expect(sessions.single.questionCount, 3);
    expect(sessions.single.answeredCount, 3);
    expect(sessions.single.status, 'completed');
    expect(sessions.single.contentPackVersion, 'test');

    final List<QuestionAttempt> attempts = await database
        .select(database.questionAttempts)
        .get();
    expect(attempts.length, 3);
    expect(attempts.map((QuestionAttempt a) => a.questionOrder).toSet(), <int>{
      0,
      1,
      2,
    });
    expect(attempts.every((QuestionAttempt a) => a.isCorrect == true), isTrue);
  });

  test('recentSessions returns newest first', () async {
    await repository.saveSession(_result(completedAt: DateTime.utc(2026)));
    await repository.saveSession(
      _result(completedAt: DateTime.utc(2026, 1, 2)),
    );

    final List<SessionSummary> sessions = await repository.recentSessions();
    expect(sessions.length, 2);
    expect(
      sessions.first.completedAtUtc.isAfter(sessions.last.completedAtUtc),
      isTrue,
    );
  });

  test('progressSummary aggregates counts and best scores', () async {
    await repository.saveSession(_result(count: 3));
    await repository.saveSession(_result(count: 3));

    final ProgressSummary summary = await repository.progressSummary();
    expect(summary.sessionCount, 2);
    expect(summary.completedCount, 2);
    expect(summary.iqBest, 100);
    expect(summary.eqBest, isNull);
    expect(summary.modeCounts[GameMode.iqChallenge], 2);
  });

  test(
    'recentQuestionIds returns deduplicated IDs from recent sessions',
    () async {
      await repository.saveSession(_result(completedAt: DateTime.utc(2026)));
      await repository.saveSession(
        _result(count: 3, completedAt: DateTime.utc(2026, 1, 2)),
      );

      final List<String> ids = await repository.recentQuestionIds();
      expect(ids, containsAll(<String>['q0', 'q1', 'q2']));
      expect(ids.toSet().length, ids.length);
    },
  );

  test('clearAll removes sessions and attempts', () async {
    await repository.saveSession(_result());

    await repository.clearAll();

    expect(await database.select(database.gameSessions).get(), isEmpty);
    expect(await database.select(database.questionAttempts).get(), isEmpty);
  });

  test('a failed save rolls back the whole transaction', () async {
    // Two questions share an id, so the second attempt violates the
    // UNIQUE(session_id, question_id) constraint mid-transaction.
    await expectLater(
      repository.saveSession(_result(duplicateId: 'dup')),
      throwsA(anything),
    );

    expect(await database.select(database.gameSessions).get(), isEmpty);
    expect(await database.select(database.questionAttempts).get(), isEmpty);
  });
}
