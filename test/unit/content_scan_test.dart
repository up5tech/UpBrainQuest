import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';

String _read(String path) => File(path).readAsStringSync();

final RegExp _digitRun = RegExp(r'\d+');
final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _numericOption = RegExp(r'^-?\d+(?:[.,]\d+)?$');

/// Counts every run of digits in [text] so reordering stays invisible.
///
/// A clock suffix is formatting, not a value: "3:00" and "3 giờ" state the
/// same time, so the trailing zeroes are dropped before counting.
Map<String, int> _numberCounts(String text) {
  final Map<String, int> counts = <String, int>{};
  for (final RegExpMatch match in _digitRun.allMatches(
    text.replaceAll(':00', ''),
  )) {
    final String token = match.group(0)!;
    counts[token] = (counts[token] ?? 0) + 1;
  }
  return counts;
}

/// Fails when [target] drops or alters a number that [source] states.
///
/// A translation may add a gloss ("quarter turn" can become "90°"), but the
/// values a player reasons with must survive unchanged.
void _expectNumbersPreserved(String reason, String source, String target) {
  final Map<String, int> expected = _numberCounts(source);
  final Map<String, int> actual = _numberCounts(target);
  for (final MapEntry<String, int> entry in expected.entries) {
    expect(
      actual[entry.key] ?? 0,
      greaterThanOrEqualTo(entry.value),
      reason: '$reason must keep the number ${entry.key}',
    );
  }
}

/// Every player-visible string of [item], keyed by where it appears.
List<MapEntry<String, String>> _copyFields(QuestionItem item) {
  final List<QuestionOption> options = switch (item) {
    MultipleChoiceItem() => item.options,
    PuzzleItem() => item.options,
    EqScenarioItem() => item.options,
  };
  return <MapEntry<String, String>>[
    if (item is EqScenarioItem)
      MapEntry<String, String>('scenarioContext', item.scenarioContext),
    MapEntry<String, String>('prompt', item.prompt),
    if (item.instructions != null)
      MapEntry<String, String>('instructions', item.instructions!),
    if (item.explanation != null)
      MapEntry<String, String>('explanation', item.explanation!),
    if (item.hint != null) MapEntry<String, String>('hint', item.hint!),
    for (final QuestionOption option in options)
      MapEntry<String, String>('option ${option.id}', option.text),
  ];
}

bool _isLanguageNeutral(String tile) => !_letter.hasMatch(tile);

/// Vietnamese writes decimals with a comma; the value must stay the same.
String _normaliseDecimal(String text) => text.replaceAll(',', '.');

/// Parses the bundled pack for [locale] straight from the files on disk.
ContentLoadSuccess _loadLocale(ContentManifest manifest, String locale) {
  final List<String> files = manifest.filesForLocale(locale);
  final Map<String, String> fileJsons = <String, String>{
    for (final String file in files) file: _read('assets/content/$file'),
  };
  final ContentLoadResult result = ContentParser.parsePack(
    manifestJson: _read('assets/content/manifest.json'),
    fileJsons: fileJsons,
    expectedLocale: locale,
  );
  expect(
    result,
    isA<ContentLoadSuccess>(),
    reason: 'locale $locale must load into a usable bank',
  );
  return result as ContentLoadSuccess;
}

void main() {
  final String manifestJson = _read('assets/content/manifest.json');
  final Map<String, dynamic> manifest =
      jsonDecode(manifestJson) as Map<String, dynamic>;
  final List<String> supportedLocales =
      (manifest['supportedLocales'] as List<dynamic>)
          .whereType<String>()
          .toList();

  test('the manifest ships exactly the languages the app offers', () {
    expect(supportedLocales, AppLanguages.supported);
  });

  test('every bundled locale loads without error', () {
    for (final String locale in supportedLocales) {
      final ContentManifest parsed = ContentParser.parseManifest(manifestJson);
      final List<String> files = parsed.filesForLocale(locale);
      expect(files, isNotEmpty, reason: 'locale $locale declares no files');

      final Map<String, String> fileJsons = <String, String>{
        for (final String file in files) file: _read('assets/content/$file'),
      };
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: manifestJson,
        fileJsons: fileJsons,
        expectedLocale: locale,
      );

      expect(result, isA<ContentLoadSuccess>(), reason: 'locale $locale');
      final ContentLoadSuccess success = result as ContentLoadSuccess;

      expect(
        success.errors,
        isEmpty,
        reason:
            'Bundled content must not contain error-severity issues '
            '(PLAN §5.2, Phase 2 acceptance).',
      );
      expect(
        success.bank.items.length,
        greaterThanOrEqualTo(8),
        reason: 'The pack should contain the authored items.',
      );

      // Per-domain coverage must match the manifest's declared counts.
      final Map<String, dynamic> expected =
          (manifest['expectedItemCounts'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      for (final MapEntry<String, dynamic> entry in expected.entries) {
        final ContentDomain? domain = ContentDomainX.tryParse(entry.key);
        expect(domain, isNotNull, reason: 'unknown domain ${entry.key}');
        final int actual = success.bank.items
            .where((QuestionItem item) => item.domain == domain)
            .length;
        expect(
          actual,
          entry.value,
          reason: 'expectedItemCounts.${entry.key} for $locale',
        );
      }

      // No duplicate IDs within a locale.
      final Set<String> ids = success.bank.items
          .map((QuestionItem item) => item.id)
          .toSet();
      expect(ids.length, success.bank.items.length, reason: 'duplicate IDs');

      // Every item is intentionally marked draft, so each one should carry a
      // draftContent warning.
      expect(
        success.warnings
            .where((ContentIssue w) => w.code == IssueCode.draftContent)
            .length,
        success.bank.items.length,
      );

      // Nothing may slip in from another language.
      expect(
        success.bank.items.every((QuestionItem item) => item.locale == locale),
        isTrue,
        reason: 'locale $locale must not mix in other languages',
      );
    }
  });

  test(
    'locales stay in sync on IDs, numbers, options, answers, and rubrics',
    () {
      final ContentManifest parsed = ContentParser.parseManifest(manifestJson);
      final Map<String, ContentLoadSuccess> banks =
          <String, ContentLoadSuccess>{
            for (final String locale in supportedLocales)
              locale: _loadLocale(parsed, locale),
          };

      final Map<String, QuestionItem> reference = <String, QuestionItem>{
        for (final QuestionItem item in banks['en']!.bank.items) item.id: item,
      };
      expect(reference, isNotEmpty);

      for (final String locale in supportedLocales.where(
        (String l) => l != 'en',
      )) {
        final Map<String, QuestionItem> translated = <String, QuestionItem>{
          for (final QuestionItem item in banks[locale]!.bank.items)
            item.id: item,
        };
        expect(
          translated.keys.toSet(),
          reference.keys.toSet(),
          reason: '$locale must define exactly the same item IDs as en',
        );

        for (final MapEntry<String, QuestionItem> entry in reference.entries) {
          final QuestionItem source = entry.value;
          final QuestionItem target = translated[entry.key]!;
          expect(target.contentType, source.contentType, reason: entry.key);
          expect(target.domain, source.domain, reason: entry.key);
          expect(target.difficulty, source.difficulty, reason: entry.key);
          expect(target.pointsWeight, source.pointsWeight, reason: entry.key);

          // Numbers identify the puzzle, so none may be dropped or reworded:
          // a lost "6" turns a sequence into a different question.
          final List<MapEntry<String, String>> sourceFields = _copyFields(
            source,
          );
          final List<MapEntry<String, String>> targetFields = _copyFields(
            target,
          );
          expect(targetFields.length, sourceFields.length, reason: entry.key);
          for (int i = 0; i < sourceFields.length; i++) {
            expect(targetFields[i].key, sourceFields[i].key, reason: entry.key);
            _expectNumbersPreserved(
              '${entry.key} ${sourceFields[i].key}',
              sourceFields[i].value,
              targetFields[i].value,
            );
          }

          if (source is MultipleChoiceItem && target is MultipleChoiceItem) {
            expect(
              target.correctOptionId,
              source.correctOptionId,
              reason: entry.key,
            );
            expect(
              target.options.map((QuestionOption o) => o.id).toList(),
              source.options.map((QuestionOption o) => o.id).toList(),
              reason: entry.key,
            );
            for (int i = 0; i < source.options.length; i++) {
              final String optionText = source.options[i].text.trim();
              if (_numericOption.hasMatch(optionText)) {
                expect(
                  target.options[i].text.trim(),
                  optionText,
                  reason:
                      '${entry.key}/${source.options[i].id} is a number and '
                      'must not be reworded',
                );
              }
            }
          }
          if (source is PuzzleItem && target is PuzzleItem) {
            switch (source.contentType) {
              case ContentType.memorySequence:
                // Digits are language-independent and must match exactly.
                expect(
                  target.expectedAnswer,
                  source.expectedAnswer,
                  reason: entry.key,
                );
                expect(
                  target.interactionConfig?['revealSequence'],
                  source.interactionConfig?['revealSequence'],
                  reason: entry.key,
                );
              case ContentType.visualPattern:
              case ContentType.oddOneOut:
              case ContentType.matchingPairs:
                // Symbol ids are language-independent; only the labels differ.
                expect(
                  target.expectedAnswer,
                  source.expectedAnswer,
                  reason: entry.key,
                );
              case ContentType.reorderSequence:
                final List<dynamic> sourceTiles =
                    (source.interactionConfig?['tiles'] as List<dynamic>?) ??
                    <dynamic>[];
                final List<dynamic> targetTiles =
                    (target.interactionConfig?['tiles'] as List<dynamic>?) ??
                    <dynamic>[];
                expect(
                  targetTiles.length,
                  sourceTiles.length,
                  reason: entry.key,
                );
                // Numeric and symbolic tiles carry the answer, so they may only
                // differ by the decimal comma; any real reword desyncs the key.
                for (int i = 0; i < sourceTiles.length; i++) {
                  final String sourceTile = sourceTiles[i].toString();
                  if (!_isLanguageNeutral(sourceTile)) {
                    continue;
                  }
                  expect(
                    _normaliseDecimal(targetTiles[i].toString()),
                    _normaliseDecimal(sourceTile),
                    reason: '${entry.key}: tile $i must not be reworded',
                  );
                }
                // The translated answer must point at the translated tiles.
                final List<String> mappedAnswer = <String>[];
                for (final dynamic answer in source.expectedAnswer) {
                  final int index = sourceTiles.indexOf(answer);
                  expect(
                    index,
                    isNonNegative,
                    reason: '${entry.key}: $answer is not one of its tiles',
                  );
                  if (index < 0) {
                    continue;
                  }
                  mappedAnswer.add(targetTiles[index].toString());
                }
                expect(target.expectedAnswer, mappedAnswer, reason: entry.key);
              case ContentType.multipleChoice:
              case ContentType.scenarioChoice:
                break;
            }
            expect(
              target.options.map((QuestionOption o) => o.id).toList(),
              source.options.map((QuestionOption o) => o.id).toList(),
              reason: entry.key,
            );
          }
          if (source is EqScenarioItem && target is EqScenarioItem) {
            expect(
              target.rubricByOption.keys.toSet(),
              source.rubricByOption.keys.toSet(),
              reason: entry.key,
            );
            for (final String optionId in source.rubricByOption.keys) {
              expect(
                target.rubricByOption[optionId]!.scores,
                source.rubricByOption[optionId]!.scores,
                reason: '${entry.key} rubric $optionId',
              );
            }
            expect(
              target.skillDimensions,
              source.skillDimensions,
              reason: entry.key,
            );
          }
        }
      }
    },
  );

  test('every EQ item can earn full marks on its practised dimension', () {
    final ContentManifest parsed = ContentParser.parseManifest(manifestJson);

    for (final String locale in supportedLocales) {
      final ContentLoadSuccess success = _loadLocale(parsed, locale);
      final List<EqScenarioItem> scenarios = success.bank.items
          .whereType<EqScenarioItem>()
          .toList();
      expect(scenarios, isNotEmpty, reason: 'locale $locale has no EQ items');

      for (final EqScenarioItem item in scenarios) {
        final EqDimension? primary = EqDimensionX.tryParse(item.skill);
        expect(
          primary,
          isNotNull,
          reason: '${item.id}: unknown EQ skill "${item.skill}"',
        );
        final EqDimension dimension = primary!;

        final List<int> totals = <int>[];
        final List<int> primaryScores = <int>[];
        for (final QuestionOption option in item.options) {
          final RubricEntry entry = item.rubricByOption[option.id]!;
          expect(
            entry.scores.keys.toSet(),
            EqDimension.values.toSet(),
            reason: '${item.id}/${option.id} must score every dimension',
          );
          expect(
            entry.scores.values.every((int score) => score >= 0 && score <= 3),
            isTrue,
            reason: '${item.id}/${option.id}: scores must stay in 0..3',
          );
          totals.add(
            entry.scores.values.fold<int>(0, (int sum, int s) => sum + s),
          );
          primaryScores.add(entry.scores[dimension]!);
        }

        // Exactly one answer may be the single best reply, otherwise the
        // result screen cannot tell the player which response was strongest.
        final List<int> sortedTotals = List<int>.of(totals)..sort();
        final int bestTotal = sortedTotals.last;
        expect(
          sortedTotals.where((int total) => total == bestTotal).length,
          1,
          reason: '${item.id} must have exactly one best answer by total',
        );

        final List<int> sortedPrimary = List<int>.of(primaryScores)..sort();
        expect(
          sortedPrimary.last,
          3,
          reason:
              '${item.id}: the strongest option must reach 3 on '
              '${item.skill}, so a perfect answer can score full marks',
        );
        expect(
          sortedPrimary.where((int score) => score == 3).length,
          1,
          reason: '${item.id}: two options claim the best ${item.skill} score',
        );
        expect(
          sortedPrimary.last - sortedPrimary.first,
          greaterThanOrEqualTo(2),
          reason:
              '${item.id}: the rubric spread on ${item.skill} is too narrow '
              'to separate a good answer from a weak one',
        );
        expect(
          sortedPrimary.first,
          lessThanOrEqualTo(1),
          reason: '${item.id}: no option represents a weak ${item.skill} reply',
        );
        expect(
          totals.indexOf(bestTotal),
          primaryScores.indexOf(3),
          reason:
              '${item.id}: the answer that practises ${item.skill} must also '
              'earn the most rubric points overall',
        );
      }
    }
  });
}
