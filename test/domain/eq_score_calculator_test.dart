import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/scoring/eq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';

/// Builds an EQ evaluation. [earnedByDim] and [possibleByDim] are the
/// per-dimension rubric totals used by the calculator.
AnswerEvaluation _eq({
  required String id,
  required Map<EqDimension, int> earnedByDim,
  required Map<EqDimension, int> possibleByDim,
}) {
  int sum(Map<EqDimension, int> m) =>
      m.values.fold<int>(0, (int a, int b) => a + b);
  return AnswerEvaluation(
    questionId: id,
    domain: ContentDomain.eq,
    skill: 'skill',
    possiblePoints: sum(possibleByDim),
    earnedPoints: sum(earnedByDim),
    rubricScores: earnedByDim,
    dimensionPossible: possibleByDim,
  );
}

AnswerEvaluation _objective({required String id}) => AnswerEvaluation(
  questionId: id,
  domain: ContentDomain.iq,
  skill: 'skill',
  possiblePoints: 1,
  earnedPoints: 1,
  isCorrect: true,
);

void main() {
  group('EqScoreCalculator', () {
    const EqScoreCalculator calc = EqScoreCalculator();

    test('exposes a stable algorithm version', () {
      expect(EqScoreCalculator.scoreAlgorithmVersion, 1);
    });

    test('best choices yield 100 and full per-dimension scores', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eq(
          id: 'a',
          earnedByDim: const <EqDimension, int>{
            EqDimension.emotionAwareness: 3,
            EqDimension.selfRegulation: 3,
          },
          possibleByDim: const <EqDimension, int>{
            EqDimension.emotionAwareness: 3,
            EqDimension.selfRegulation: 3,
          },
        ),
      ]);
      expect(r.valid, isTrue);
      expect(r.score, 100);
      expect(r.earned, 6);
      expect(r.possible, 6);
      expect(r.dimensionScore(EqDimension.emotionAwareness), 100);
      expect(r.dimensionScore(EqDimension.selfRegulation), 100);
    });

    test('partial rubric credit is proportional', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eq(
          id: 'a',
          earnedByDim: const <EqDimension, int>{
            EqDimension.emotionAwareness: 2,
            EqDimension.selfRegulation: 1,
          },
          possibleByDim: const <EqDimension, int>{
            EqDimension.emotionAwareness: 3,
            EqDimension.selfRegulation: 3,
          },
        ),
      ]);
      expect(r.score, 50);
      expect(r.earned, 3);
      expect(r.possible, 6);
    });

    test('objective items are excluded from the EQ score', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _objective(id: 'iq'),
        _eq(
          id: 'a',
          earnedByDim: const <EqDimension, int>{
            EqDimension.perspectiveTaking: 3,
          },
          possibleByDim: const <EqDimension, int>{
            EqDimension.perspectiveTaking: 6,
          },
        ),
      ]);
      expect(r.valid, isTrue);
      expect(r.possible, 6);
      expect(r.score, 50);
      expect(r.dimensions, <EqDimension>[EqDimension.perspectiveTaking]);
    });

    test('per-dimension scores normalise across items', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eq(
          id: 'a',
          earnedByDim: const <EqDimension, int>{
            EqDimension.boundariesAndAgency: 2,
          },
          possibleByDim: const <EqDimension, int>{
            EqDimension.boundariesAndAgency: 3,
          },
        ),
        _eq(
          id: 'b',
          earnedByDim: const <EqDimension, int>{
            EqDimension.boundariesAndAgency: 1,
          },
          possibleByDim: const <EqDimension, int>{
            EqDimension.boundariesAndAgency: 3,
          },
        ),
      ]);
      // 3 earned / 6 possible for the dimension => 50.
      expect(r.dimensionScore(EqDimension.boundariesAndAgency), 50);
    });

    test('no EQ items yields an invalid result with no dimensions', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _objective(id: 'iq'),
      ]);
      expect(r.valid, isFalse);
      expect(r.score, isNull);
      expect(r.dimensions, isEmpty);
      expect(r.dimensionScore(EqDimension.emotionAwareness), 0);
    });

    test('empty input yields an invalid result', () {
      final EqScoreResult r = calc.calculate(<AnswerEvaluation>[]);
      expect(r.valid, isFalse);
      expect(r.score, isNull);
    });
  });
}
