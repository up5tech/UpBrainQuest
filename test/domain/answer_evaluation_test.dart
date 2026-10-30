import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';

MultipleChoiceItem _mc({
  required String id,
  required String correctOptionId,
  int pointsWeight = 1,
}) => MultipleChoiceItem(
  id: id,
  domain: ContentDomain.iq,
  contentType: ContentType.multipleChoice,
  skill: 'pattern_recognition',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Prompt',
  options: const <QuestionOption>[
    QuestionOption(id: 'a', text: 'A'),
    QuestionOption(id: 'b', text: 'B'),
  ],
  correctOptionId: correctOptionId,
  explanation: 'Because.',
  pointsWeight: pointsWeight,
  tags: const <String>['t'],
  status: ContentStatus.finalStatus,
);

PuzzleItem _memory({
  required String id,
  required List<int> expected,
  int pointsWeight = 1,
}) => PuzzleItem(
  id: id,
  domain: ContentDomain.puzzle,
  contentType: ContentType.memorySequence,
  skill: 'memory',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Memorize',
  expectedAnswer: expected,
  interactionConfig: <String, dynamic>{
    'length': expected.length,
    'minValue': 1,
    'maxValue': 9,
  },
  pointsWeight: pointsWeight,
  tags: const <String>['m'],
  status: ContentStatus.finalStatus,
);

PuzzleItem _reorder({
  required String id,
  required List<String> expected,
  int pointsWeight = 1,
}) => PuzzleItem(
  id: id,
  domain: ContentDomain.puzzle,
  contentType: ContentType.reorderSequence,
  skill: 'ordering',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Order',
  expectedAnswer: expected,
  interactionConfig: <String, dynamic>{'tiles': expected},
  pointsWeight: pointsWeight,
  tags: const <String>['r'],
  status: ContentStatus.finalStatus,
);

void main() {
  group('evaluateAnswer', () {
    test('multiple-choice correct answer scores full weight', () {
      final AnswerEvaluation e = evaluateAnswer(
        _mc(id: 'q1', correctOptionId: 'a'),
        const SelectedOptionAnswer('a'),
      );
      expect(e.isCorrect, isTrue);
      expect(e.earnedPoints, 1);
      expect(e.possiblePoints, 1);
    });

    test('multiple-choice wrong answer scores zero', () {
      final AnswerEvaluation e = evaluateAnswer(
        _mc(id: 'q1', correctOptionId: 'a'),
        const SelectedOptionAnswer('b'),
      );
      expect(e.isCorrect, isFalse);
      expect(e.earnedPoints, 0);
      expect(e.possiblePoints, 1);
    });

    test('unanswered question stays in the denominator', () {
      final AnswerEvaluation e = evaluateAnswer(
        _mc(id: 'q1', correctOptionId: 'a', pointsWeight: 2),
        const UnansweredAnswer(),
      );
      expect(e.isCorrect, isFalse);
      expect(e.earnedPoints, 0);
      expect(e.possiblePoints, 2);
    });

    test('memory-sequence correct sequence scores full weight', () {
      final AnswerEvaluation e = evaluateAnswer(
        _memory(id: 'm1', expected: <int>[3, 7, 1, 9]),
        const SequenceAnswer(<int>[3, 7, 1, 9]),
      );
      expect(e.isCorrect, isTrue);
      expect(e.earnedPoints, 1);
    });

    test('memory-sequence wrong sequence scores zero', () {
      final AnswerEvaluation e = evaluateAnswer(
        _memory(id: 'm1', expected: <int>[3, 7, 1, 9]),
        const SequenceAnswer(<int>[3, 7, 9, 1]),
      );
      expect(e.isCorrect, isFalse);
      expect(e.earnedPoints, 0);
    });

    test('reorder correct order scores full weight', () {
      final AnswerEvaluation e = evaluateAnswer(
        _reorder(id: 'r1', expected: <String>['a', 'b', 'c']),
        const ReorderAnswer(<String>['a', 'b', 'c']),
      );
      expect(e.isCorrect, isTrue);
      expect(e.earnedPoints, 1);
    });

    test('reorder wrong order scores zero', () {
      final AnswerEvaluation e = evaluateAnswer(
        _reorder(id: 'r1', expected: <String>['a', 'b', 'c']),
        const ReorderAnswer(<String>['c', 'b', 'a']),
      );
      expect(e.isCorrect, isFalse);
      expect(e.earnedPoints, 0);
    });

    test('EQ item is non-binary with rubric feedback', () {
      const EqScenarioItem item = EqScenarioItem(
        id: 'eq1',
        domain: ContentDomain.eq,
        contentType: ContentType.scenarioChoice,
        skill: 'constructive_communication',
        difficulty: Difficulty.medium,
        locale: 'en',
        prompt: 'What do you do?',
        scenarioContext: 'A friend is upset.',
        options: <QuestionOption>[
          QuestionOption(id: 'a', text: 'Listen'),
          QuestionOption(id: 'b', text: 'Ignore'),
        ],
        rubricByOption: <String, RubricEntry>{
          'a': RubricEntry(
            scores: <EqDimension, int>{EqDimension.emotionAwareness: 3},
            feedback: 'Great listening.',
          ),
          'b': RubricEntry(
            scores: <EqDimension, int>{EqDimension.emotionAwareness: 0},
            feedback: 'Try listening.',
          ),
        },
        tags: <String>['eq'],
        status: ContentStatus.finalStatus,
      );
      final AnswerEvaluation e = evaluateAnswer(
        item,
        const SelectedOptionAnswer('a'),
      );
      expect(e.isCorrect, isNull);
      expect(e.earnedPoints, 3);
      expect(e.feedback, 'Great listening.');
      expect(e.rubricScores, isNotNull);
    });
  });
}
