import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';
import 'package:up_brain_quest/domain/session/game_mode.dart';
import 'package:up_brain_quest/domain/session/selection_error.dart';
import 'package:up_brain_quest/domain/session/session_builder.dart';
import 'package:up_brain_quest/domain/session/session_plan.dart';
import 'package:up_brain_quest/domain/session/session_request.dart';

MultipleChoiceItem _mc({
  required String id,
  required ContentDomain domain,
  required Difficulty difficulty,
  String correctOptionId = 'a',
  int pointsWeight = 1,
}) {
  return MultipleChoiceItem(
    id: id,
    domain: domain,
    contentType: ContentType.multipleChoice,
    skill: 'pattern_recognition',
    difficulty: difficulty,
    locale: 'en',
    prompt: 'Prompt for $id',
    options: const <QuestionOption>[
      QuestionOption(id: 'a', text: 'A'),
      QuestionOption(id: 'b', text: 'B'),
    ],
    correctOptionId: correctOptionId,
    explanation: 'Because.',
    pointsWeight: pointsWeight,
    tags: const <String>['test'],
    status: ContentStatus.finalStatus,
  );
}

ContentBank _bank(List<QuestionItem> items) => ContentBank(
  manifest: const ContentManifest(
    schemaVersion: 1,
    contentPackVersion: 'test',
    supportedLocales: <String>['en'],
    files: <String>['en/items.json'],
  ),
  items: items,
);

SessionRequest _request({
  GameMode mode = GameMode.iqChallenge,
  int count = 3,
  Set<Difficulty>? difficulties,
  List<String> recentQuestionIds = const <String>[],
  int? seed,
}) => SessionRequest(
  mode: mode,
  count: count,
  difficulties: difficulties,
  recentQuestionIds: recentQuestionIds,
  seed: seed,
);

void main() {
  group('SessionBuilder', () {
    final List<QuestionItem> items = <QuestionItem>[
      _mc(id: 'iq1', domain: ContentDomain.iq, difficulty: Difficulty.easy),
      _mc(id: 'iq2', domain: ContentDomain.iq, difficulty: Difficulty.medium),
      _mc(id: 'iq3', domain: ContentDomain.iq, difficulty: Difficulty.hard),
      _mc(id: 'pz1', domain: ContentDomain.puzzle, difficulty: Difficulty.easy),
      _mc(id: 'eq1', domain: ContentDomain.eq, difficulty: Difficulty.easy),
    ];
    final ContentBank bank = _bank(items);
    const SessionBuilder builder = SessionBuilder();

    test('candidates for iqChallenge include iq and puzzle, exclude eq', () {
      final List<QuestionItem> cands = builder.candidates(_request(), bank);
      expect(cands.map((q) => q.id), containsAll(<String>['iq1', 'pz1']));
      expect(cands.map((q) => q.id), isNot(contains('eq1')));
    });

    test('candidateCount reflects the filtered pool', () {
      expect(builder.candidateCount(_request(), bank), 4);
      expect(
        builder.candidateCount(_request(mode: GameMode.eqChallenge), bank),
        1,
      );
    });

    test('accepts() enforces each mode domain set', () {
      expect(SessionBuilder.accepts(GameMode.iqChallenge, items[0]), isTrue);
      expect(SessionBuilder.accepts(GameMode.iqChallenge, items[3]), isTrue);
      expect(SessionBuilder.accepts(GameMode.iqChallenge, items[4]), isFalse);
      expect(SessionBuilder.accepts(GameMode.eqChallenge, items[4]), isTrue);
      expect(SessionBuilder.accepts(GameMode.puzzleSprint, items[0]), isFalse);
      expect(SessionBuilder.accepts(GameMode.quickQuest, items[4]), isTrue);
    });

    test('build returns the requested count with no duplicates', () {
      final SessionPlan plan = builder.build(
        request: _request(),
        bank: bank,
        rng: Random(42),
      );
      expect(plan.items.length, 3);
      final Set<String> ids = plan.items.map((q) => q.id).toSet();
      expect(ids.length, 3);
    });

    test('difficulty filter narrows the pool', () {
      final SessionPlan plan = builder.build(
        request: _request(
          count: 2,
          difficulties: <Difficulty>{Difficulty.easy},
        ),
        bank: bank,
        rng: Random(7),
      );
      expect(plan.items.length, 2);
      expect(plan.items.every((q) => q.difficulty == Difficulty.easy), isTrue);
    });

    test('recent ids are avoided when alternatives exist', () {
      final SessionPlan plan = builder.build(
        request: _request(recentQuestionIds: <String>['iq1', 'iq2', 'iq3']),
        bank: bank,
        rng: Random(1),
      );
      // The single fresh item must be preferred over the recent ones.
      expect(plan.items.map((q) => q.id), contains('pz1'));
      expect(plan.items.length, 3);
      // Three recent ids cannot all appear in a 3-slot plan that already
      // reserves one slot for the fresh item.
      expect(
        plan.items.map((q) => q.id),
        isNot(containsAll(<String>['iq1', 'iq2', 'iq3'])),
      );
    });

    test('same seed yields a deterministic order', () {
      final SessionPlan a = builder.build(
        request: _request(count: 4),
        bank: bank,
        rng: Random(99),
      );
      final SessionPlan b = builder.build(
        request: _request(count: 4),
        bank: bank,
        rng: Random(99),
      );
      expect(
        a.items.map((q) => q.id).toList(),
        b.items.map((q) => q.id).toList(),
      );
    });

    test('throws QuestionSelectionFailure when pool is too small', () {
      expect(
        () => builder.build(
          request: _request(count: 10),
          bank: bank,
          rng: Random(1),
        ),
        throwsA(isA<QuestionSelectionFailure>()),
      );
    });

    test('quick quest honours the 5/2/3 domain mix', () {
      final List<QuestionItem> mixed = <QuestionItem>[
        for (int i = 0; i < 16; i++)
          _mc(
            id: 'iq$i',
            domain: ContentDomain.iq,
            difficulty: Difficulty.easy,
          ),
        for (int i = 0; i < 2; i++)
          _mc(
            id: 'pz$i',
            domain: ContentDomain.puzzle,
            difficulty: Difficulty.easy,
          ),
        for (int i = 0; i < 16; i++)
          _mc(
            id: 'eq$i',
            domain: ContentDomain.eq,
            difficulty: Difficulty.easy,
          ),
      ];
      final SessionPlan plan = builder.build(
        request: _request(mode: GameMode.quickQuest, count: 10),
        bank: _bank(mixed),
        rng: Random(3),
      );
      expect(plan.items.length, 10);
      expect(plan.items.where((q) => q.domain == ContentDomain.iq).length, 5);
      expect(
        plan.items.where((q) => q.domain == ContentDomain.puzzle).length,
        2,
      );
      expect(plan.items.where((q) => q.domain == ContentDomain.eq).length, 3);
      expect(plan.items.map((q) => q.id).toSet().length, 10);
    });

    test('quick quest throws when a targeted domain is absent', () {
      final List<QuestionItem> iqOnly = <QuestionItem>[
        for (int i = 0; i < 16; i++)
          _mc(
            id: 'iq$i',
            domain: ContentDomain.iq,
            difficulty: Difficulty.easy,
          ),
      ];
      expect(
        () => builder.build(
          request: _request(mode: GameMode.quickQuest, count: 10),
          bank: _bank(iqOnly),
          rng: Random(1),
        ),
        throwsA(isA<QuestionSelectionFailure>()),
      );
    });

    test('an explicit domainMix overrides the mode default', () {
      final List<QuestionItem> mixed = <QuestionItem>[
        for (int i = 0; i < 5; i++)
          _mc(
            id: 'iq$i',
            domain: ContentDomain.iq,
            difficulty: Difficulty.easy,
          ),
        for (int i = 0; i < 5; i++)
          _mc(
            id: 'eq$i',
            domain: ContentDomain.eq,
            difficulty: Difficulty.easy,
          ),
      ];
      const SessionRequest request = SessionRequest(
        mode: GameMode.quickQuest,
        count: 4,
        domainMix: <ContentDomain, int>{
          ContentDomain.iq: 2,
          ContentDomain.eq: 2,
        },
      );
      final SessionPlan plan = builder.build(
        request: request,
        bank: _bank(mixed),
        rng: Random(5),
      );
      expect(plan.items.length, 4);
      expect(plan.items.where((q) => q.domain == ContentDomain.iq).length, 2);
      expect(plan.items.where((q) => q.domain == ContentDomain.eq).length, 2);
    });
  });
}
