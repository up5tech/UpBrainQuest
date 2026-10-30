import 'package:up_brain_quest/domain/session/answer_evaluation.dart';

/// Calculates the IQ Challenge Score: a 0–100 in-game performance score,
/// never a standardized IQ value (PLAN §4.1, §4.2).
///
/// `score = round(100 * earnedWeightedPoints / possibleWeightedPoints)`.
/// EQ evaluations carry `isCorrect == null` and are excluded from the
/// denominator (PLAN §4.3). If the denominator is zero the result is invalid
/// and no numeric score is shown (PLAN §4.2).
class IqScoreCalculator {
  const IqScoreCalculator();

  /// Persisted algorithm version for historical interpretability (PLAN §4.5).
  static const int scoreAlgorithmVersion = 1;

  IqScoreResult calculate(List<AnswerEvaluation> results) {
    int earned = 0;
    int possible = 0;
    for (final AnswerEvaluation result in results) {
      if (result.isCorrect == null) continue; // EQ items excluded
      possible += result.possiblePoints;
      earned += result.earnedPoints;
    }
    if (possible == 0) {
      return const IqScoreResult.invalid();
    }
    final int score = ((earned * 100) / possible).round().clamp(0, 100);
    return IqScoreResult(
      valid: true,
      score: score,
      earned: earned,
      possible: possible,
    );
  }
}

/// The outcome of [IqScoreCalculator.calculate].
class IqScoreResult {
  const IqScoreResult({
    required this.valid,
    required this.score,
    required this.earned,
    required this.possible,
  }) : assert(
         valid || (score == null && earned == 0 && possible == 0),
         'An invalid result must not carry a numeric score.',
       );

  const IqScoreResult.invalid()
    : valid = false,
      score = null,
      earned = 0,
      possible = 0;

  /// Whether a numeric score could be computed.
  final bool valid;

  /// The 0–100 in-game score, or `null` when [valid] is false.
  final int? score;

  /// Weighted points earned across the session.
  final int earned;

  /// Weighted points possible across the session.
  final int possible;
}
