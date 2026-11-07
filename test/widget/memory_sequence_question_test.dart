import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/theme/app_spacing.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/features/gameplay/widgets/memory_sequence_question.dart';

import '../support/test_app.dart';

PuzzleItem _item() => const PuzzleItem(
  id: 'puz_memory_medium_001',
  domain: ContentDomain.puzzle,
  contentType: ContentType.memorySequence,
  skill: 'memory_sequence',
  difficulty: Difficulty.medium,
  locale: 'en',
  prompt: 'Remember the six numbers.',
  expectedAnswer: <dynamic>[4, 6, 2, 8, 1, 9],
  tags: <String>['memory'],
  status: ContentStatus.finalStatus,
);

Rect _tileRect(WidgetTester tester, int number) {
  return tester.getRect(
    find
        .ancestor(of: find.text('$number'), matching: find.byType(Container))
        .first,
  );
}

void main() {
  group('MemorySequenceQuestionWidget', () {
    testWidgets('keeps a gap between wrapped rows of reveal numbers', (
      WidgetTester tester,
    ) async {
      // 320dp is the narrow phone the layout has to survive (PLAN §11.6); the
      // six tiles wrap there, which is where the rows used to touch.
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: MemorySequenceQuestionWidget(
                item: _item(),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final Map<double, List<Rect>> rows = <double, List<Rect>>{};
      for (final int number in <int>[4, 6, 2, 8, 1, 9]) {
        final Rect rect = _tileRect(tester, number);
        rows.putIfAbsent(rect.top, () => <Rect>[]).add(rect);
      }

      expect(rows.length, greaterThanOrEqualTo(2));
      final List<double> tops = rows.keys.toList()..sort();
      final double firstRowBottom = rows[tops[0]]!
          .map((Rect rect) => rect.bottom)
          .reduce(math.max);
      expect(
        tops[1] - firstRowBottom,
        greaterThanOrEqualTo(AppSpacing.md),
        reason: 'wrapped rows must keep the same gap as the columns',
      );
    });
  });
}
