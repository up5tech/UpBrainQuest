import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';

const String _manifest = '''
{
  "schemaVersion": 1,
  "contentPackVersion": "test",
  "supportedLocales": ["en"],
  "files": ["en/items.json"],
  "expectedItemCounts": { "iq": 1 }
}
''';

Map<String, String> _pack(String itemsJson) => <String, String>{
  'en/items.json':
      '''
{
  "schemaVersion": 1,
  "contentPackVersion": "test",
  "items": $itemsJson
}
''',
};

void main() {
  group('ContentParser', () {
    test('parses a valid multiple-choice item', () {
      const String items = '''
      [
        {
          "id": "iq_1",
          "domain": "iq",
          "contentType": "multiple_choice",
          "skill": "pattern_recognition",
          "difficulty": "easy",
          "locale": "en",
          "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "b",
          "explanation": "Because.",
          "pointsWeight": 1,
          "contentVersion": 1,
          "status": "final"
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      expect(result, isA<ContentLoadSuccess>());
      final ContentLoadSuccess success = result as ContentLoadSuccess;
      expect(success.errors, isEmpty);
      expect(success.bank.items.length, 1);
      expect(success.bank.items.first.id, 'iq_1');
    });

    test('malformed manifest JSON yields a typed failure', () {
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: '{ not valid json',
        fileJsons: <String, String>{},
      );
      expect(result, isA<ContentLoadFailure>());
      expect(result.errors, isNotEmpty);
      expect(result.errors.first.code, IssueCode.manifestInvalid);
    });

    test('item with missing id is excluded and reported', () {
      const String items = '''
      [
        {
          "domain": "iq",
          "contentType": "multiple_choice",
          "difficulty": "easy",
          "locale": "en",
          "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "b",
          "explanation": "Because."
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      expect(result, isA<ContentLoadFailure>());
      expect(result.errors.first.code, IssueCode.missingId);
    });

    test('duplicate ids keep the first and report the rest', () {
      const String items = '''
      [
        {
          "id": "dup", "domain": "iq", "contentType": "multiple_choice",
          "difficulty": "easy", "locale": "en", "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "b", "explanation": "Because.", "status":"final"
        },
        {
          "id": "dup", "domain": "iq", "contentType": "multiple_choice",
          "difficulty": "easy", "locale": "en", "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "b", "explanation": "Because.", "status":"final"
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      final ContentLoadSuccess success = result as ContentLoadSuccess;
      expect(success.bank.items.length, 1);
      expect(
        result.errors.where(
          (ContentIssue e) => e.code == IssueCode.duplicateId,
        ),
        isNotEmpty,
      );
    });

    test('invalid correctOptionId excludes the item', () {
      const String items = '''
      [
        {
          "id": "iq_x", "domain": "iq", "contentType": "multiple_choice",
          "difficulty": "easy", "locale": "en", "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "z", "explanation": "Because.", "status":"final"
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      expect(result, isA<ContentLoadFailure>());
      expect(result.errors.first.code, IssueCode.invalidCorrectOption);
    });

    test('EQ scenario with out-of-range rubric score is excluded', () {
      const String items = '''
      [
        {
          "id": "eq_x", "domain": "eq", "contentType": "scenario_choice",
          "skill": "constructive_communication", "difficulty": "medium",
          "locale": "en", "status":"final",
          "scenarioContext": "Context.",
          "prompt": "What now?",
          "options": [{"id":"a","text":"Do A"},{"id":"b","text":"Do B"}],
          "rubricByOption": {
            "a": {"scores": {"emotion_awareness": 9}, "feedback": "ok"},
            "b": {"scores": {"emotion_awareness": 1}, "feedback": "ok"}
          }
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      expect(result, isA<ContentLoadFailure>());
      expect(result.errors.first.code, IssueCode.rubricScoreOutOfRange);
    });

    test('EQ scenario missing a rubric for an option is excluded', () {
      const String items = '''
      [
        {
          "id": "eq_y", "domain": "eq", "contentType": "scenario_choice",
          "skill": "constructive_communication", "difficulty": "medium",
          "locale": "en", "status":"final",
          "scenarioContext": "Context.",
          "prompt": "What now?",
          "options": [{"id":"a","text":"Do A"},{"id":"b","text":"Do B"}],
          "rubricByOption": {
            "a": {"scores": {"emotion_awareness": 2}, "feedback": "ok"}
          }
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      expect(result, isA<ContentLoadFailure>());
      expect(result.errors.first.code, IssueCode.missingRubric);
    });

    test('draft items load but emit a warning, not an error', () {
      const String items = '''
      [
        {
          "id": "iq_d", "domain": "iq", "contentType": "multiple_choice",
          "difficulty": "easy", "locale": "en", "prompt": "Next?",
          "options": [{"id":"a","text":"1"},{"id":"b","text":"2"}],
          "correctOptionId": "b", "explanation": "Because.", "status":"draft"
        }
      ]
      ''';
      final ContentLoadResult result = ContentParser.parsePack(
        manifestJson: _manifest,
        fileJsons: _pack(items),
      );
      final ContentLoadSuccess success = result as ContentLoadSuccess;
      expect(success.bank.items.length, 1);
      expect(success.errors, isEmpty);
      expect(
        success.warnings.where(
          (ContentIssue w) => w.code == IssueCode.draftContent,
        ),
        isNotEmpty,
      );
    });
  });
}
