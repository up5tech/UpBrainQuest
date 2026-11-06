import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/data/content/content_loader.dart';
import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_manifest.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';

/// Guards the gap between authoring and shipping: a content file can exist on
/// disk and still be absent from the app bundle when `pubspec.yaml` declares a
/// directory without its subdirectories. The parser tests use in-memory
/// fixtures, so only the real bundle can catch this.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every manifest-listed content file ships in the app bundle', () async {
    final String manifestJson = await rootBundle.loadString(
      'assets/content/manifest.json',
    );
    final ContentManifest manifest = ContentParser.parseManifest(manifestJson);

    for (final String file in manifest.files) {
      final String json = await rootBundle.loadString('assets/content/$file');
      expect(
        json,
        isNotEmpty,
        reason: 'assets/content/$file must be declared in pubspec assets.',
      );
    }
  });

  test('every bundled locale loads into a playable content bank', () async {
    final String manifestJson = await rootBundle.loadString(
      'assets/content/manifest.json',
    );
    final ContentManifest manifest = ContentParser.parseManifest(manifestJson);

    expect(manifest.supportedLocales, isNotEmpty);
    for (final String locale in manifest.supportedLocales) {
      final ContentLoadResult result = await ContentLoader(locale: locale)
          .load();

      expect(
        result,
        isA<ContentLoadSuccess>(),
        reason:
            'The app must bundle the question JSON for "$locale", not just '
            'the manifest (see pubspec.yaml assets).',
      );
      final ContentLoadSuccess success = result as ContentLoadSuccess;
      expect(success.errors, isEmpty);
      expect(success.bank.items, isNotEmpty);
      expect(success.bank.byDomain(ContentDomain.iq), isNotEmpty);
      expect(success.bank.byDomain(ContentDomain.puzzle), isNotEmpty);
      expect(success.bank.byDomain(ContentDomain.eq), isNotEmpty);
      expect(
        success.bank.items.every((QuestionItem item) => item.locale == locale),
        isTrue,
        reason: 'Loading "$locale" must never mix in another language.',
      );
    }
  });
}
