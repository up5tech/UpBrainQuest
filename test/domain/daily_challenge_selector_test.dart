import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/daily/daily.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/session_builder.dart';
import 'package:up_brain_quest/domain/session/session_plan.dart';
import 'package:up_brain_quest/domain/session/session_request.dart';

MultipleChoiceItem _mc(String id) => MultipleChoiceItem(
  id: id,
  domain: ContentDomain.iq,
  contentType: ContentType.multipleChoice,
  skill: 'pattern_recognition',
  difficulty: Difficulty.easy,
  locale: 'en',
  prompt: 'Prompt $id',
  options: const <QuestionOption>[
    QuestionOption(id: 'a', text: 'A'),
    QuestionOption(id: 'b', text: 'B'),
  ],
  correctOptionId: 'a',
  explanation: 'Because.',
  tags: const <String>['test'],
  status: ContentStatus.finalStatus,
);

ContentBank _bank(int count) => ContentBank(
  manifest: const ContentManifest(
    schemaVersion: 1,
    contentPackVersion: '1.0.0',
    supportedLocales: <String>['en'],
    files: <String>['en/items.json'],
  ),
  items: <QuestionItem>[for (int i = 0; i < count; i++) _mc('q$i')],
);

void main() {
  group('DailyChallengeSelector', () {
    const DailyChallengeSelector selector = DailyChallengeSelector();

    test('same date and content version produce the same seed', () {
      final int a = selector.seedFor(
        localDate: '2026-01-10',
        contentVersion: '1.0.0',
      );
      final int b = selector.seedFor(
        localDate: '2026-01-10',
        contentVersion: '1.0.0',
      );
      expect(a, b);
    });

    test('a different date or content version changes the seed', () {
      final int base = selector.seedFor(
        localDate: '2026-01-10',
        contentVersion: '1.0.0',
      );
      expect(
        selector.seedFor(localDate: '2026-01-11', contentVersion: '1.0.0'),
        isNot(base),
      );
      expect(
        selector.seedFor(localDate: '2026-01-10', contentVersion: '1.0.1'),
        isNot(base),
      );
    });

    test('daily selection is deterministic for the same date and version', () {
      final ContentBank bank = _bank(20);
      final int seed = selector.seedFor(
        localDate: '2026-01-10',
        contentVersion: '1.0.0',
      );
      final SessionRequest request = SessionRequest(
        mode: GameMode.dailyChallenge,
        count: DailyChallengeSelector.questionCount,
        seed: seed,
      );
      final SessionPlan a = const SessionBuilder().build(
        request: request,
        bank: bank,
        rng: Random(seed),
      );
      final SessionPlan b = const SessionBuilder().build(
        request: request,
        bank: bank,
        rng: Random(seed),
      );
      expect(
        a.items.map((QuestionItem q) => q.id).toList(),
        b.items.map((QuestionItem q) => q.id).toList(),
      );
      expect(a.items.length, DailyChallengeSelector.questionCount);
    });

    test('a different date yields a different daily set', () {
      final ContentBank bank = _bank(20);
      final int seedA = selector.seedFor(
        localDate: '2026-01-10',
        contentVersion: '1.0.0',
      );
      final int seedB = selector.seedFor(
        localDate: '2026-01-11',
        contentVersion: '1.0.0',
      );
      final SessionPlan a = const SessionBuilder().build(
        request: SessionRequest(
          mode: GameMode.dailyChallenge,
          count: DailyChallengeSelector.questionCount,
          seed: seedA,
        ),
        bank: bank,
        rng: Random(seedA),
      );
      final SessionPlan b = const SessionBuilder().build(
        request: SessionRequest(
          mode: GameMode.dailyChallenge,
          count: DailyChallengeSelector.questionCount,
          seed: seedB,
        ),
        bank: bank,
        rng: Random(seedB),
      );
      expect(
        a.items.map((QuestionItem q) => q.id).toList(),
        isNot(b.items.map((QuestionItem q) => q.id).toList()),
      );
    });
  });
}
