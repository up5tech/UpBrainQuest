import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/content/content_loader.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';

/// An in-memory [AssetBundle] so the loader can be exercised without a real
/// asset bundle or any network access (PLAN §7.4).
class MemoryAssetBundle extends AssetBundle {
  final Map<String, String> _strings = <String, String>{};

  void setString(String key, String value) => _strings[key] = value;

  @override
  Future<ByteData> load(String key) async {
    final String? value = _strings[key];
    if (value == null) {
      throw Exception('Asset not found: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final String? value = _strings[key];
    if (value == null) {
      throw Exception('Asset not found: $key');
    }
    return value;
  }
}

const String _manifest = '''
{
  "schemaVersion": 1,
  "contentPackVersion": "test",
  "supportedLocales": ["en"],
  "files": ["en/items.json"],
  "expectedItemCounts": { "iq": 1 }
}
''';

const String _itemsFile = '''
{
  "schemaVersion": 1,
  "contentPackVersion": "test",
  "items": [
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
}
''';

void main() {
  test('ContentLoader reads from an injected bundle without network', () async {
    final MemoryAssetBundle bundle = MemoryAssetBundle()
      ..setString('assets/content/manifest.json', _manifest)
      ..setString('assets/content/en/items.json', _itemsFile);

    final ContentLoader loader = ContentLoader(bundle: bundle);
    final ContentLoadResult result = await loader.load();

    expect(result, isA<ContentLoadSuccess>());
    final ContentLoadSuccess success = result as ContentLoadSuccess;
    expect(success.errors, isEmpty);
    expect(success.bank.items.length, 1);
    expect(success.bank.items.first.id, 'iq_1');
  });
}
