import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/scoring/iq_score_calculator.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';

AnswerEvaluation _eval({
  required String id,
  int possible = 1,
  int earned = 1,
  bool? isCorrect = true,
}) => AnswerEvaluation(
  questionId: id,
  domain: ContentDomain.iq,
  skill: 'skill',
  possiblePoints: possible,
  earnedPoints: earned,
  isCorrect: isCorrect,
);

void main() {
  group('IqScoreCalculator', () {
    const IqScoreCalculator calc = IqScoreCalculator();

    test('exposes a stable algorithm version', () {
      expect(IqScoreCalculator.scoreAlgorithmVersion, 1);
    });

    test('all correct yields 100', () {
      final IqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eval(id: 'a'),
        _eval(id: 'b'),
      ]);
      expect(r.valid, isTrue);
      expect(r.score, 100);
      expect(r.earned, 2);
      expect(r.possible, 2);
    });

    test('weighted partial credit is proportional', () {
      // 1 easy (1pt earned) + 1 hard (2pts missed) => 1/3 => 33.
      final IqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eval(id: 'a'),
        _eval(id: 'b', possible: 2, earned: 0, isCorrect: false),
      ]);
      expect(r.score, 33);
      expect(r.earned, 1);
      expect(r.possible, 3);
    });

    test('wrong answers stay in the denominator', () {
      // 1 correct (1pt) + 1 wrong (1pt possible) => 1/2 => 50.
      final IqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eval(id: 'a'),
        _eval(id: 'b', earned: 0, isCorrect: false),
      ]);
      expect(r.score, 50);
      expect(r.possible, 2);
    });

    test('EQ evaluations are excluded from the denominator', () {
      // One MC correct plus one EQ (isCorrect null) => 100, possible 1.
      final IqScoreResult r = calc.calculate(<AnswerEvaluation>[
        _eval(id: 'mc'),
        const AnswerEvaluation(
          questionId: 'eq',
          domain: ContentDomain.eq,
          skill: 'skill',
          possiblePoints: 3,
          earnedPoints: 0,
        ),
      ]);
      expect(r.valid, isTrue);
      expect(r.score, 100);
      expect(r.possible, 1);
    });

    test('zero possible points yields an invalid result', () {
      final IqScoreResult r = calc.calculate(<AnswerEvaluation>[
        const AnswerEvaluation(
          questionId: 'eq',
          domain: ContentDomain.eq,
          skill: 'skill',
          possiblePoints: 0,
          earnedPoints: 0,
        ),
      ]);
      expect(r.valid, isFalse);
      expect(r.score, isNull);
    });
  });
}
