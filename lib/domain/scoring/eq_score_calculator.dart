import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';

/// Calculates the EQ Practice Score: a 0–100 in-game practice score derived
/// from explicit author-defined rubrics, never a validated EQ assessment (PLAN
/// §4.3).
///
/// `score = round(100 * earnedRubricPoints / possibleRubricPoints)`. Component
/// skill dimensions are tracked separately so a single aggregate does not
/// conceal what was practised. Only EQ evaluations (`isCorrect == null`)
/// contribute; objective IQ/puzzle items are excluded from the denominator.
class EqScoreCalculator {
  const EqScoreCalculator();

  /// Persisted algorithm version for historical interpretability (PLAN §4.5).
  static const int scoreAlgorithmVersion = 1;

  EqScoreResult calculate(List<AnswerEvaluation> results) {
    int earned = 0;
    int possible = 0;
    final Map<EqDimension, int> dimEarned = <EqDimension, int>{};
    final Map<EqDimension, int> dimPossible = <EqDimension, int>{};

    for (final AnswerEvaluation result in results) {
      if (result.isCorrect != null) continue; // only EQ items count
      earned += result.earnedPoints;
      possible += result.possiblePoints;
      result.dimensionPossible?.forEach((EqDimension dim, int p) {
        dimPossible[dim] = (dimPossible[dim] ?? 0) + p;
      });
      final Map<EqDimension, int>? earnedByDim = result.rubricScores;
      if (earnedByDim != null) {
        earnedByDim.forEach((EqDimension dim, int e) {
          dimEarned[dim] = (dimEarned[dim] ?? 0) + e;
        });
      }
    }

    if (possible == 0) {
      return const EqScoreResult.invalid();
    }
    final int score = ((earned * 100) / possible).round().clamp(0, 100);
    return EqScoreResult(
      valid: true,
      score: score,
      earned: earned,
      possible: possible,
      dimensionEarned: dimEarned,
      dimensionPossible: dimPossible,
    );
  }
}

/// The outcome of [EqScoreCalculator.calculate].
class EqScoreResult {
  const EqScoreResult({
    required this.valid,
    required this.score,
    required this.earned,
    required this.possible,
    required this.dimensionEarned,
    required this.dimensionPossible,
  }) : assert(
         valid || (score == null && earned == 0 && possible == 0),
         'An invalid result must not carry a numeric score.',
       );

  const EqScoreResult.invalid()
    : valid = false,
      score = null,
      earned = 0,
      possible = 0,
      dimensionEarned = const <EqDimension, int>{},
      dimensionPossible = const <EqDimension, int>{};

  /// Whether a numeric score could be computed.
  final bool valid;

  /// The 0–100 in-game practice score, or `null` when [valid] is false.
  final int? score;

  /// Weighted rubric points earned across the session.
  final int earned;

  /// Weighted rubric points possible across the session.
  final int possible;

  /// Earned rubric points per practised skill dimension.
  final Map<EqDimension, int> dimensionEarned;

  /// Maximum possible rubric points per practised skill dimension.
  final Map<EqDimension, int> dimensionPossible;

  /// Dimensions this session practised, per the content rubrics.
  List<EqDimension> get dimensions => dimensionPossible.keys.toList();

  /// Per-dimension sub-score, 0–100, or 0 when the dimension had no possible
  /// points. Useful for an honest, granular breakdown (PLAN §4.3).
  int dimensionScore(EqDimension dimension) {
    final int possibleForDim = dimensionPossible[dimension] ?? 0;
    if (possibleForDim == 0) return 0;
    final int earnedForDim = dimensionEarned[dimension] ?? 0;
    return ((earnedForDim * 100) / possibleForDim).round().clamp(0, 100);
  }
}
