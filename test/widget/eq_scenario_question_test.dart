import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/eq_scenario_question.dart';

import '../support/test_app.dart';

/// English strings used by assertions (the app default locale).
final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));

/// Border colour of the option tile whose text is [label].
Color? _tileBorder(WidgetTester tester, String label) {
  final Container container = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  final BoxDecoration decoration = container.decoration! as BoxDecoration;
  return (decoration.border! as Border).top.color;
}

EqScenarioItem _item() => const EqScenarioItem(
  id: 'eq1',
  domain: ContentDomain.eq,
  contentType: ContentType.scenarioChoice,
  skill: 'emotion_awareness',
  difficulty: Difficulty.medium,
  locale: 'en',
  prompt: 'What do you do?',
  scenarioContext: 'A tense meeting.',
  options: <QuestionOption>[
    QuestionOption(id: 'a', text: 'Option A'),
    QuestionOption(id: 'b', text: 'Option B'),
    QuestionOption(id: 'c', text: 'Option C'),
  ],
  rubricByOption: <String, RubricEntry>{
    'a': RubricEntry(
      scores: <EqDimension, int>{EqDimension.emotionAwareness: 3},
      feedback: 'Feedback A',
    ),
    'b': RubricEntry(
      scores: <EqDimension, int>{EqDimension.emotionAwareness: 1},
      feedback: 'Feedback B',
    ),
    'c': RubricEntry(
      scores: <EqDimension, int>{EqDimension.emotionAwareness: 0},
      feedback: 'Feedback C',
    ),
  },
  tags: <String>['t'],
  status: ContentStatus.finalStatus,
);

void main() {
  group('EqScenarioQuestionWidget', () {
    testWidgets('renders options and reports the selection', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: EqScenarioQuestionWidget(
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

    testWidgets('locked widget marks the response without good/bad framing', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final EqScenarioItem item = _item();
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: EqScenarioQuestionWidget(
              item: item,
              submission: const SelectedOptionAnswer('a'),
              evaluation: const AnswerEvaluation(
                questionId: 'eq1',
                domain: ContentDomain.eq,
                skill: 'emotion_awareness',
                possiblePoints: 3,
                earnedPoints: 3,
                rubricScores: <EqDimension, int>{
                  EqDimension.emotionAwareness: 3,
                },
                dimensionPossible: <EqDimension, int>{
                  EqDimension.emotionAwareness: 3,
                },
                feedback: 'Feedback A',
              ),
              onChanged: (_) => tapped = true,
            ),
          ),
        ),
      );

      // EQ is non-binary: it marks "your response", never correct/incorrect.
      expect(find.text(enStrings.sessionYourResponse), findsOneWidget);
      expect(find.text(enStrings.sessionCorrect), findsNothing);
      expect(find.text(enStrings.sessionIncorrect), findsNothing);

      // Tapping the locked option must not fire onChanged.
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('keeps the chosen tile highlighted across parent rebuilds', (
      WidgetTester tester,
    ) async {
      final EqScenarioItem item = _item();
      Widget tree() => localizedTestApp(
        Scaffold(
          body: EqScenarioQuestionWidget(item: item, onChanged: (_) {}),
        ),
      );

      await tester.pumpWidget(tree());
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();
      expect(_tileBorder(tester, 'Option B'), AppColors.primary);

      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      expect(_tileBorder(tester, 'Option B'), AppColors.primary);
    });
  });
}
