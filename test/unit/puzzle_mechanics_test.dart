import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

PuzzleItem _puzzle({
  required ContentType contentType,
  required List<dynamic> expected,
  int? maxFlips,
}) => PuzzleItem(
  id: 'q1',
  domain: ContentDomain.puzzle,
  contentType: contentType,
  skill: 'x',
  difficulty: Difficulty.medium,
  locale: 'en',
  prompt: 'Prompt',
  expectedAnswer: expected,
  interactionConfig: maxFlips == null
      ? null
      : <String, dynamic>{'maxFlips': maxFlips},
  tags: const <String>[],
  status: ContentStatus.finalStatus,
);

void main() {
  group('evaluateAnswer symbol mechanics', () {
    test('visual_pattern accepts only the authored symbol', () {
      final PuzzleItem item = _puzzle(
        contentType: ContentType.visualPattern,
        expected: <dynamic>['circle'],
      );

      expect(
        evaluateAnswer(item, const SelectedOptionAnswer('circle')).isCorrect,
        isTrue,
      );
      expect(
        evaluateAnswer(item, const SelectedOptionAnswer('square')).isCorrect,
        isFalse,
      );
      expect(evaluateAnswer(item, const UnansweredAnswer()).isCorrect, isFalse);
    });

    test('odd_one_out scores a single selection', () {
      final PuzzleItem item = _puzzle(
        contentType: ContentType.oddOneOut,
        expected: <dynamic>['circle'],
      );

      final AnswerEvaluation evaluation = evaluateAnswer(
        item,
        const SelectedOptionAnswer('circle'),
      );
      expect(evaluation.isCorrect, isTrue);
      expect(evaluation.earnedPoints, 1);
      expect(evaluation.possiblePoints, 1);
    });
  });

  group('evaluateAnswer matching_pairs', () {
    final PuzzleItem item = _puzzle(
      contentType: ContentType.matchingPairs,
      expected: <dynamic>['symbol_star', 'symbol_moon', 'symbol_leaf'],
      maxFlips: 10,
    );

    test('all pairs inside the budget is correct regardless of order', () {
      final AnswerEvaluation evaluation = evaluateAnswer(
        item,
        const PairMatchAnswer(
          pairIds: <String>['symbol_leaf', 'symbol_star', 'symbol_moon'],
          flips: 8,
        ),
      );
      expect(evaluation.isCorrect, isTrue);
    });

    test('spending more flips than the budget is incorrect', () {
      final AnswerEvaluation evaluation = evaluateAnswer(
        item,
        const PairMatchAnswer(
          pairIds: <String>['symbol_leaf', 'symbol_star', 'symbol_moon'],
          flips: 11,
        ),
      );
      expect(evaluation.isCorrect, isFalse);
    });

    test('a partial board is incorrect', () {
      final AnswerEvaluation evaluation = evaluateAnswer(
        item,
        const PairMatchAnswer(pairIds: <String>['symbol_star'], flips: 4),
      );
      expect(evaluation.isCorrect, isFalse);
    });

    test('a plain selection cannot stand in for pair matching', () {
      expect(
        evaluateAnswer(
          item,
          const SelectedOptionAnswer('symbol_star'),
        ).isCorrect,
        isFalse,
      );
    });
  });

  group('evaluateAnswer memory variants', () {
    test('revealSequence does not change the scored answer', () {
      final PuzzleItem item = _puzzle(
        contentType: ContentType.memorySequence,
        expected: <dynamic>[4, 9, 2, 6],
      );

      expect(
        evaluateAnswer(item, const SequenceAnswer(<int>[4, 9, 2, 6])).isCorrect,
        isTrue,
      );
      expect(
        evaluateAnswer(item, const SequenceAnswer(<int>[6, 2, 9, 4])).isCorrect,
        isFalse,
      );
    });
  });
}
