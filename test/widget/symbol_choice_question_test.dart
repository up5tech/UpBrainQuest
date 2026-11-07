import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/symbol_choice_question.dart';

import '../support/test_app.dart';

final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));

/// Border colour of the option tile whose text is [label].
Color? _tileBorder(WidgetTester tester, String label) {
  final Container container = tester.widget<Container>(
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first,
  );
  final BoxDecoration decoration = container.decoration! as BoxDecoration;
  return (decoration.border! as Border).top.color;
}

PuzzleItem _item() => const PuzzleItem(
  id: 'puz_pattern_easy_001',
  domain: ContentDomain.puzzle,
  contentType: ContentType.visualPattern,
  skill: 'visual_pattern',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Which shape comes next?',
  expectedAnswer: <dynamic>['circle'],
  options: <QuestionOption>[
    QuestionOption(id: 'circle', text: 'Circle'),
    QuestionOption(id: 'square', text: 'Square'),
    QuestionOption(id: 'triangle', text: 'Triangle'),
  ],
  interactionConfig: <String, dynamic>{
    'previewSymbols': <String>['circle', 'square', 'blank'],
  },
  tags: <String>['shapes'],
  status: ContentStatus.finalStatus,
);

void main() {
  group('SymbolChoiceQuestionWidget', () {
    testWidgets('renders every symbol and reports the tapped one', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: SymbolChoiceQuestionWidget(
              item: _item(),
              onChanged: (PlayerAnswer? answer) => captured = answer,
            ),
          ),
        ),
      );

      // Two preview symbols plus the empty slot for the missing one.
      expect(find.byIcon(Icons.circle_outlined), findsWidgets);
      expect(find.text('Circle'), findsOneWidget);
      expect(find.text('Square'), findsOneWidget);
      expect(find.text('Triangle'), findsOneWidget);
      expect(captured, isNull);

      await tester.tap(find.text('Circle'));
      await tester.pumpAndSettle();

      expect(captured, isA<SelectedOptionAnswer>());
      expect((captured! as SelectedOptionAnswer).optionId, 'circle');
    });

    testWidgets('locked widget marks the answer and ignores taps', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final PuzzleItem item = _item();
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: SymbolChoiceQuestionWidget(
              item: item,
              submission: const SelectedOptionAnswer('circle'),
              evaluation: const AnswerEvaluation(
                questionId: 'puz_pattern_easy_001',
                domain: ContentDomain.puzzle,
                skill: 'visual_pattern',
                possiblePoints: 1,
                earnedPoints: 1,
                isCorrect: true,
              ),
              onChanged: (_) => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(enStrings.sessionCorrect), findsOneWidget);

      await tester.tap(find.text('Circle'));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('keeps the chosen tile highlighted across parent rebuilds', (
      WidgetTester tester,
    ) async {
      final PuzzleItem item = _item();
      Widget tree() => localizedTestApp(
        Scaffold(
          body: SymbolChoiceQuestionWidget(item: item, onChanged: (_) {}),
        ),
      );

      await tester.pumpWidget(tree());
      await tester.tap(find.text('Circle'));
      await tester.pumpAndSettle();
      expect(_tileBorder(tester, 'Circle'), AppColors.primary);

      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      expect(_tileBorder(tester, 'Circle'), AppColors.primary);
    });
  });
}
