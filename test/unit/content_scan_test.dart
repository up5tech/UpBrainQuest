import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('every bundled content file loads without error', () {
    final String manifestJson = _read('assets/content/manifest.json');

    // Enumerate the declared files straight from the manifest so the test stays
    // in sync as the content pack grows.
    final Map<String, dynamic> manifest =
        jsonDecode(manifestJson) as Map<String, dynamic>;
    final List<String> files = (manifest['files'] as List<dynamic>)
        .whereType<String>()
        .toList();

    final Map<String, String> fileJsons = <String, String>{};
    for (final String file in files) {
      fileJsons[file] = _read('assets/content/$file');
    }

    final ContentLoadResult result = ContentParser.parsePack(
      manifestJson: manifestJson,
      fileJsons: fileJsons,
    );

    expect(result, isA<ContentLoadSuccess>());
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
      reason: 'The starter pack should contain the drafted items.',
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
      expect(actual, entry.value, reason: 'expectedItemCounts.${entry.key}');
    }

    // No duplicate IDs.
    final Set<String> ids = success.bank.items
        .map((QuestionItem item) => item.id)
        .toSet();
    expect(ids.length, success.bank.items.length, reason: 'duplicate IDs');

    // All starter content is intentionally marked draft, so every item should
    // carry a draftContent warning — confirming labels are surfaced.
    expect(
      success.warnings
          .where((ContentIssue w) => w.code == IssueCode.draftContent)
          .length,
      success.bank.items.length,
    );
  });
}
