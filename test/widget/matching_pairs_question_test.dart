import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/answer_evaluation.dart';
import 'package:up_brain_quest/domain/session/player_answer.dart';
import 'package:up_brain_quest/features/gameplay/widgets/matching_pairs_question.dart';

import '../support/test_app.dart';

final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));

const List<String> _pairs = <String>[
  'symbol_star',
  'symbol_moon',
  'symbol_leaf',
];

PuzzleItem _item({int maxFlips = 14}) => PuzzleItem(
  id: 'puz_match_hard_001',
  domain: ContentDomain.puzzle,
  contentType: ContentType.matchingPairs,
  skill: 'matching_pairs',
  difficulty: Difficulty.hard,
  locale: 'en',
  prompt: 'Find all three matching pairs.',
  expectedAnswer: _pairs,
  options: const <QuestionOption>[
    QuestionOption(id: 'symbol_star', text: 'Star'),
    QuestionOption(id: 'symbol_moon', text: 'Moon'),
    QuestionOption(id: 'symbol_leaf', text: 'Leaf'),
  ],
  interactionConfig: <String, dynamic>{'maxFlips': maxFlips},
  tags: const <String>['pairs'],
  status: ContentStatus.finalStatus,
);

/// Mirrors the widget's seeded shuffle so the test can address cards by index.
List<String> _board() {
  final List<String> cards = <String>[..._pairs, ..._pairs]
    ..shuffle(Random(_seedFor('puz_match_hard_001')));
  return cards;
}

int _seedFor(String id) {
  int hash = 7;
  for (final int unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

Finder _cardAt(int index) => find.byType(InkWell).at(index);

void main() {
  group('MatchingPairsQuestionWidget', () {
    testWidgets('lays out six face-down cards and reports nothing yet', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: MatchingPairsQuestionWidget(
              item: _item(),
              onChanged: (PlayerAnswer? answer) => captured = answer,
            ),
          ),
        ),
      );

      expect(_board().length, 6);
      expect(
        find.bySemanticsLabel(enStrings.sessionPairsHiddenCard),
        findsNWidgets(6),
      );
      expect(find.text(enStrings.sessionPairsFound(0, 3)), findsOneWidget);
      expect(find.text(enStrings.sessionPairsFlipsLeft(14)), findsOneWidget);
      expect(captured, isNull);
    });

    testWidgets('reports every pair once the board is solved', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: MatchingPairsQuestionWidget(
              item: _item(),
              onChanged: (PlayerAnswer? answer) => captured = answer,
            ),
          ),
        ),
      );

      final List<String> board = _board();
      for (final String pair in _pairs) {
        final List<int> indexes = <int>[
          for (int i = 0; i < board.length; i++)
            if (board[i] == pair) i,
        ];
        expect(indexes.length, 2, reason: 'pair $pair must appear twice');
        await tester.tap(_cardAt(indexes[0]));
        await tester.pump();
        await tester.tap(_cardAt(indexes[1]));
        await tester.pump();
      }

      expect(captured, isA<PairMatchAnswer>());
      final PairMatchAnswer answer = captured! as PairMatchAnswer;
      expect(answer.pairIds.toSet(), _pairs.toSet());
      expect(answer.flips, 6);
      expect(find.text(enStrings.sessionPairsFound(3, 3)), findsOneWidget);
    });

    testWidgets('stops after the flip budget and reports a partial answer', (
      WidgetTester tester,
    ) async {
      PlayerAnswer? captured;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: MatchingPairsQuestionWidget(
              item: _item(maxFlips: 4),
              onChanged: (PlayerAnswer? answer) => captured = answer,
            ),
          ),
        ),
      );

      final List<String> board = _board();
      // Turn one pairs card 0 with a different symbol, turn two does the same
      // with two other cards, so the budget is spent without finding a pair.
      final int firstDiff = board.indexWhere((String s) => s != board[0]);
      final int second = board.indexWhere((String s) => false);
      int filler = 1;
      while (filler == firstDiff) {
        filler++;
      }
      final int lastDiff = board.indexWhere(
        (String s) => s != board[filler] && s != board[0],
      );
      expect(firstDiff, greaterThan(0));
      expect(second, -1);
      expect(lastDiff, greaterThan(0));

      for (final int index in <int>[0, firstDiff, filler, lastDiff]) {
        await tester.tap(_cardAt(index));
        await tester.pump();
      }

      expect(captured, isA<PairMatchAnswer>());
      final PairMatchAnswer answer = captured! as PairMatchAnswer;
      expect(answer.flips, 4);
      expect(answer.pairIds, isEmpty);
      expect(find.text(enStrings.sessionPairsBudgetSpent), findsOneWidget);
    });

    testWidgets('locked widget shows the result and ignores taps', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final PuzzleItem item = _item();
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: MatchingPairsQuestionWidget(
              item: item,
              submission: const PairMatchAnswer(pairIds: _pairs, flips: 6),
              evaluation: const AnswerEvaluation(
                questionId: 'puz_match_hard_001',
                domain: ContentDomain.puzzle,
                skill: 'matching_pairs',
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
      await tester.tap(_cardAt(0));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });
}
