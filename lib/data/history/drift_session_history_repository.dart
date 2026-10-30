import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import 'package:up_brain_quest/data/database/app_database.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/history/progress_summary.dart';
import 'package:up_brain_quest/domain/history/session_history_repository.dart';
import 'package:up_brain_quest/domain/history/session_summary.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/domain/session/session_result.dart';

/// Drift-backed [SessionHistoryRepository] (PLAN §7.1–§7.3).
///
/// Every write happens inside one transaction so a session and its attempts are
/// either both persisted or neither is. All timestamps are stored in UTC.
class DriftSessionHistoryRepository implements SessionHistoryRepository {
  DriftSessionHistoryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveSession(SessionResult result) async {
    await _db.transaction(() async {
      final int sessionId = await _db
          .into(_db.gameSessions)
          .insert(
            GameSessionsCompanion.insert(
              mode: result.mode.key,
              status: const Value<String>('completed'),
              startedAt: result.startedAtUtc ?? result.completedAtUtc,
              completedAt: Value<DateTime?>(result.completedAtUtc),
              durationMs: Value<int?>(result.duration?.inMilliseconds),
              questionCount: result.questionCount,
              answeredCount: result.answeredCount,
              iqScore: Value<int?>(
                result.iqScore.valid ? result.iqScore.score : null,
              ),
              eqScore: Value<int?>(
                result.eqScore.valid ? result.eqScore.score : null,
              ),
              earnedPoints: Value<int?>(_earned(result)),
              possiblePoints: Value<int?>(_possible(result)),
              scoreAlgorithmVersion: result.scoreAlgorithmVersion,
              contentPackVersion: Value<String>(result.contentPackVersion),
            ),
          );

      for (int i = 0; i < result.questions.length; i++) {
        final QuestionItem item = result.questions[i];
        final PlayerAnswer? answer = result.answers[i];
        final AnswerEvaluation? evaluation = result.evaluations[i];
        await _db
            .into(_db.questionAttempts)
            .insert(
              QuestionAttemptsCompanion.insert(
                sessionId: sessionId,
                questionId: item.id,
                domain: item.domain.name,
                skill: item.skill,
                questionOrder: i,
                submittedAnswerJson: Value<String>(_encodeAnswer(answer)),
                isCorrect: Value<bool?>(evaluation?.isCorrect),
                earnedPoints: Value<int>(evaluation?.earnedPoints ?? 0),
                possiblePoints: Value<int>(evaluation?.possiblePoints ?? 0),
                rubricScoresJson: Value<String?>(
                  _encodeRubric(evaluation?.rubricScores),
                ),
              ),
            );
      }
    });
  }

  @override
  Future<List<SessionSummary>> recentSessions({int limit = 20}) async {
    final List<GameSession> rows =
        await (_db.select(_db.gameSessions)
              ..orderBy(<OrderClauseGenerator<$GameSessionsTable>>[
                ($GameSessionsTable t) => OrderingTerm.desc(t.completedAt),
              ])
              ..limit(limit))
            .get();
    return rows.map(_toSummary).toList();
  }

  @override
  Future<List<String>> recentQuestionIds({int limit = 20}) async {
    // Only the most recent sessions matter for "avoid immediate repetition";
    // pulling too many would starve the pool on small content banks.
    final List<GameSession> sessions =
        await (_db.select(_db.gameSessions)
              ..orderBy(<OrderClauseGenerator<$GameSessionsTable>>[
                ($GameSessionsTable t) => OrderingTerm.desc(t.completedAt),
              ])
              ..limit(2))
            .get();
    final List<String> result = <String>[];
    final Set<String> seen = <String>{};
    for (final GameSession session in sessions) {
      final List<QuestionAttempt> attempts = await (_db.select(
        _db.questionAttempts,
      )..where((t) => t.sessionId.equals(session.id))).get();
      for (final QuestionAttempt attempt in attempts) {
        if (seen.add(attempt.questionId)) result.add(attempt.questionId);
        if (result.length >= limit) return result;
      }
    }
    return result;
  }

  @override
  Future<ProgressSummary> progressSummary() async {
    final List<GameSession> rows = await _db.select(_db.gameSessions).get();
    int completed = 0;
    int? iqBest;
    int? eqBest;
    final Map<GameMode, int> modeCounts = <GameMode, int>{};
    for (final GameSession row in rows) {
      if (row.status == 'completed') completed++;
      final int? iq = row.iqScore;
      if (iq != null) iqBest = iqBest == null ? iq : math.max(iqBest, iq);
      final int? eq = row.eqScore;
      if (eq != null) eqBest = eqBest == null ? eq : math.max(eqBest, eq);
      final GameMode? mode = GameModeX.tryParse(row.mode);
      if (mode != null) modeCounts[mode] = (modeCounts[mode] ?? 0) + 1;
    }
    return ProgressSummary(
      sessionCount: rows.length,
      completedCount: completed,
      modeCounts: modeCounts,
      iqBest: iqBest,
      eqBest: eqBest,
    );
  }

  @override
  Future<void> clearAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.questionAttempts).go();
      await _db.delete(_db.gameSessions).go();
    });
  }

  SessionSummary _toSummary(GameSession row) => SessionSummary(
    id: row.id,
    mode: GameModeX.tryParse(row.mode) ?? GameMode.quickQuest,
    completedAtUtc: row.completedAt ?? row.startedAt,
    questionCount: row.questionCount,
    answeredCount: row.answeredCount,
    iqScore: row.iqScore,
    eqScore: row.eqScore,
  );

  int? _earned(SessionResult result) {
    if (!result.iqScore.valid && !result.eqScore.valid) return null;
    final int iq = result.iqScore.valid ? result.iqScore.earned : 0;
    final int eq = result.eqScore.valid ? result.eqScore.earned : 0;
    return iq + eq;
  }

  int? _possible(SessionResult result) {
    if (!result.iqScore.valid && !result.eqScore.valid) return null;
    final int iq = result.iqScore.valid ? result.iqScore.possible : 0;
    final int eq = result.eqScore.valid ? result.eqScore.possible : 0;
    return iq + eq;
  }

  String _encodeAnswer(PlayerAnswer? answer) {
    if (answer == null || answer is UnansweredAnswer) {
      return jsonEncode(<String, Object?>{'type': 'unanswered'});
    }
    if (answer is SelectedOptionAnswer) {
      return jsonEncode(<String, Object?>{
        'type': 'selected_option',
        'optionId': answer.optionId,
      });
    }
    if (answer is SequenceAnswer) {
      return jsonEncode(<String, Object?>{
        'type': 'sequence',
        'sequence': answer.sequence,
      });
    }
    if (answer is ReorderAnswer) {
      return jsonEncode(<String, Object?>{
        'type': 'reorder',
        'order': answer.order,
      });
    }
    return jsonEncode(<String, Object?>{'type': 'unknown'});
  }

  String? _encodeRubric(Map<EqDimension, int>? scores) {
    if (scores == null || scores.isEmpty) return null;
    return jsonEncode(<String, int>{
      for (final MapEntry<EqDimension, int> entry in scores.entries)
        entry.key.key: entry.value,
    });
  }
}
