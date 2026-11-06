import 'package:up_brain_quest/domain/content/content_enums.dart';
import 'package:up_brain_quest/domain/content/content_helpers.dart';
import 'package:up_brain_quest/domain/content/question_models.dart';

/// Describes the bundled content pack (PLAN §5.2).
class ContentManifest {
  const ContentManifest({
    required this.schemaVersion,
    required this.contentPackVersion,
    required this.supportedLocales,
    required this.files,
    this.expectedItemCounts,
  });

  final int schemaVersion;
  final String contentPackVersion;
  final List<String> supportedLocales;
  final List<String> files;
  final Map<String, int>? expectedItemCounts;

  /// Whether this pack ships content for [locale].
  bool supportsLocale(String locale) => supportedLocales.contains(locale);

  /// Files that belong to [locale] (paths are locale-prefixed, e.g.
  /// `vi/iq_questions.json`).
  List<String> filesForLocale(String locale) =>
      files.where((String file) => file.startsWith('$locale/')).toList();

  /// Parses the manifest envelope. Throws [ContentFieldException] when a
  /// required field is missing so the caller can convert it into a typed
  /// failure.
  static ContentManifest fromJson(Map<String, dynamic> json) {
    final int? schemaVersion = json['schemaVersion'] as int?;
    final String? contentPackVersion = readString(json['contentPackVersion']);
    final List<String> supportedLocales = stringList(json['supportedLocales']);
    final List<String> files = stringList(json['files']);
    final Map<String, int>? expectedItemCounts = intMap(
      json['expectedItemCounts'],
    );

    if (schemaVersion == null) {
      throw const ContentFieldException('manifest.schemaVersion');
    }
    if (contentPackVersion == null || contentPackVersion.isEmpty) {
      throw const ContentFieldException('manifest.contentPackVersion');
    }
    if (files.isEmpty) {
      throw const ContentFieldException('manifest.files');
    }

    return ContentManifest(
      schemaVersion: schemaVersion,
      contentPackVersion: contentPackVersion,
      supportedLocales: supportedLocales,
      files: files,
      expectedItemCounts: expectedItemCounts,
    );
  }
}

/// The validated, usable content pack: a manifest plus every valid item.
class ContentBank {
  const ContentBank({required this.manifest, required this.items});

  final ContentManifest manifest;
  final List<QuestionItem> items;

  QuestionItem? findById(String id) {
    for (final QuestionItem item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<QuestionItem> byDomain(ContentDomain domain) =>
      items.where((QuestionItem i) => i.domain == domain).toList();

  List<QuestionItem> byContentType(ContentType contentType) =>
      items.where((QuestionItem i) => i.contentType == contentType).toList();
}
