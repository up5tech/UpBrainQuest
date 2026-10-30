import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

/// The outcome of evaluating a player's [PlayerAnswer] against a question.
///
/// Objective items (IQ / puzzle) carry [isCorrect]; EQ items leave it `null`
/// and instead report [rubricScores] (PLAN §4.3).
class AnswerEvaluation {
  const AnswerEvaluation({
    required this.questionId,
    required this.domain,
    required this.skill,
    required this.possiblePoints,
    required this.earnedPoints,
    this.isCorrect,
    this.rubricScores,
    this.dimensionPossible,
    this.feedback,
  });

  final String questionId;
  final ContentDomain domain;
  final String skill;

  /// Maximum points the question could contribute. Zero for an unknown item.
  final int possiblePoints;

  /// Points actually earned by the submitted answer.
  final int earnedPoints;

  /// `true`/`false` for objectively scored items; `null` for EQ items.
  final bool? isCorrect;

  /// EQ rubric dimension scores, present only for EQ items.
  final Map<EqDimension, int>? rubricScores;

  /// Maximum attainable rubric score per dimension for the item, present only
  /// for EQ items. Used by [EqScoreCalculator] to normalise the per-dimension
  /// sub-scores (PLAN §4.3).
  final Map<EqDimension, int>? dimensionPossible;

  /// Author-provided feedback shown after answering (EQ or generic).
  final String? feedback;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _rubricTotal(RubricEntry entry) {
  int sum = 0;
  for (final int value in entry.scores.values) {
    sum += value;
  }
  return sum;
}

int _maxRubricPoints(EqScenarioItem item) {
  int max = 0;
  for (final RubricEntry entry in item.rubricByOption.values) {
    final int total = _rubricTotal(entry);
    if (total > max) max = total;
  }
  return max;
}

/// Evaluates [answer] against [item] using the content-defined rules.
///
/// Pure function — no Flutter, no I/O — so it is unit-testable in isolation
/// (PLAN §6.3, §4.2).
AnswerEvaluation evaluateAnswer(QuestionItem item, PlayerAnswer answer) {
  if (item is MultipleChoiceItem) {
    return _evaluateMultipleChoice(item, answer);
  }
  if (item is PuzzleItem) {
    return _evaluatePuzzle(item, answer);
  }
  if (item is EqScenarioItem) {
    return _evaluateEq(item, answer);
  }
  // Defensive: an unknown item type should never reach this point.
  return AnswerEvaluation(
    questionId: item.id,
    domain: item.domain,
    skill: item.skill,
    possiblePoints: 0,
    earnedPoints: 0,
    isCorrect: false,
  );
}

AnswerEvaluation _evaluateMultipleChoice(
  MultipleChoiceItem item,
  PlayerAnswer answer,
) {
  final int weight = item.pointsWeight ?? 1;
  final bool correct =
      answer is SelectedOptionAnswer && answer.optionId == item.correctOptionId;
  return AnswerEvaluation(
    questionId: item.id,
    domain: item.domain,
    skill: item.skill,
    possiblePoints: weight,
    earnedPoints: correct ? weight : 0,
    isCorrect: correct,
  );
}

AnswerEvaluation _evaluatePuzzle(PuzzleItem item, PlayerAnswer answer) {
  final int weight = item.pointsWeight ?? 1;
  final List<dynamic> expected = item.expectedAnswer;
  final bool correct;
  if (item.contentType == ContentType.memorySequence) {
    correct =
        answer is SequenceAnswer &&
        _listEquals(expected.cast<int>(), answer.sequence);
  } else if (item.contentType == ContentType.reorderSequence) {
    correct =
        answer is ReorderAnswer &&
        _listEquals(expected.cast<String>(), answer.order);
  } else {
    correct = false;
  }
  return AnswerEvaluation(
    questionId: item.id,
    domain: item.domain,
    skill: item.skill,
    possiblePoints: weight,
    earnedPoints: correct ? weight : 0,
    isCorrect: correct,
  );
}

AnswerEvaluation _evaluateEq(EqScenarioItem item, PlayerAnswer answer) {
  final int possible = _maxRubricPoints(item);
  final Map<EqDimension, int> dimPossible = <EqDimension, int>{};
  for (final RubricEntry entry in item.rubricByOption.values) {
    entry.scores.forEach((EqDimension dim, int value) {
      final int current = dimPossible[dim] ?? 0;
      if (value > current) dimPossible[dim] = value;
    });
  }
  if (answer is! SelectedOptionAnswer) {
    return AnswerEvaluation(
      questionId: item.id,
      domain: item.domain,
      skill: item.skill,
      possiblePoints: possible,
      earnedPoints: 0,
      dimensionPossible: dimPossible,
    );
  }
  final RubricEntry? rubric = item.rubricByOption[answer.optionId];
  if (rubric == null) {
    return AnswerEvaluation(
      questionId: item.id,
      domain: item.domain,
      skill: item.skill,
      possiblePoints: possible,
      earnedPoints: 0,
      dimensionPossible: dimPossible,
    );
  }
  return AnswerEvaluation(
    questionId: item.id,
    domain: item.domain,
    skill: item.skill,
    possiblePoints: possible,
    earnedPoints: _rubricTotal(rubric),
    rubricScores: rubric.scores,
    dimensionPossible: dimPossible,
    feedback: rubric.feedback,
  );
}
