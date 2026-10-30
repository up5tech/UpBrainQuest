import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

/// Immutable snapshot of a finished session, used by the result and review
/// screens (PLAN §3.1, §5).
class SessionResult {
  const SessionResult({
    required this.mode,
    required this.questions,
    required this.answers,
    required this.evaluations,
    required this.scoreAlgorithmVersion,
    required this.iqScore,
    required this.eqScore,
    this.startedAtUtc,
    this.contentPackVersion = '',
    required this.completedAtUtc,
  });

  final GameMode mode;
  final List<QuestionItem> questions;
  final List<PlayerAnswer?> answers;
  final List<AnswerEvaluation?> evaluations;
  final int scoreAlgorithmVersion;
  final IqScoreResult iqScore;

  /// EQ practice summary. Invalid (`possible == 0`) for sessions with no EQ
  /// items, so the result screen can omit it rather than show a fake zero.
  final EqScoreResult eqScore;

  /// Session start in UTC, when known. Used to persist `duration_ms`
  /// (PLAN §7.2).
  final DateTime? startedAtUtc;

  /// Content-pack version the session ran against, for historical
  /// interpretability (PLAN §4.5).
  final String contentPackVersion;

  final DateTime completedAtUtc;

  /// Elapsed duration when [startedAtUtc] is known.
  Duration? get duration {
    final DateTime? started = startedAtUtc;
    if (started == null) return null;
    return completedAtUtc.difference(started);
  }

  // Phase 5 intentionally does NOT persist a secondary "Quest Completion
  // Score". PLAN §4.4 / Phase 5 task 3 allow omission unless the formula is
  // fixed, documented and tested; two honest per-domain scores are preferred
  // to an invented composite that could be mistaken for a real IQ/EQ blend.

  /// Number of questions in the session.
  int get questionCount => questions.length;

  /// Number of questions that received a real (non-skip) response.
  int get answeredCount {
    int count = 0;
    for (final PlayerAnswer? answer in answers) {
      if (answer != null && answer is! UnansweredAnswer) count++;
    }
    return count;
  }

  /// Whether every question received a real response.
  bool get isComplete => answeredCount == questionCount;

  /// Number of objectively scored (IQ/puzzle) questions answered correctly.
  int get correctCount {
    int count = 0;
    for (final AnswerEvaluation? e in evaluations) {
      if (e != null && e.isCorrect == true) count++;
    }
    return count;
  }

  /// Number of objectively scored questions in the session.
  int get objectiveCount {
    int count = 0;
    for (final AnswerEvaluation? e in evaluations) {
      if (e != null && e.isCorrect != null) count++;
    }
    return count;
  }
}
