import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/multiple_choice_question.dart';

MultipleChoiceItem _item() => const MultipleChoiceItem(
  id: 'q1',
  domain: ContentDomain.iq,
  contentType: ContentType.multipleChoice,
  skill: 'pattern_recognition',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Pick the right one.',
  options: <QuestionOption>[
    QuestionOption(id: 'a', text: 'Option A'),
    QuestionOption(id: 'b', text: 'Option B'),
    QuestionOption(id: 'c', text: 'Option C'),
  ],
  correctOptionId: 'b',
  explanation: 'Because B.',
  tags: <String>['t'],
  status: ContentStatus.finalStatus,
);

void main() {
  group('MultipleChoiceQuestionWidget', () {
    testWidgets('renders options and reports the selection', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleChoiceQuestionWidget(
              item: _item(),
              onChanged: (PlayerAnswer? a) => captured = a,
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);

      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      expect(captured, isA<SelectedOptionAnswer>());
      expect((captured as SelectedOptionAnswer).optionId, 'b');
    });

    testWidgets('locked widget shows the correct label and ignores taps', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final MultipleChoiceItem item = _item();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleChoiceQuestionWidget(
              item: item,
              submission: const SelectedOptionAnswer('b'),
              evaluation: AnswerEvaluation(
                questionId: item.id,
                domain: item.domain,
                skill: item.skill,
                possiblePoints: 1,
                earnedPoints: 1,
                isCorrect: true,
              ),
              onChanged: (_) => tapped = true,
            ),
          ),
        ),
      );

      // The correct option is marked with the positive label.
      expect(find.text(AppStrings.sessionCorrect), findsWidgets);
      // Tapping the locked option must not fire onChanged.
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });
  });
}
