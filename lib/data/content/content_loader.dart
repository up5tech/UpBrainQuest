import 'package:flutter/services.dart';

import 'package:up_brain_quest/core/logging/app_logger.dart';
import 'package:up_brain_quest/domain/content/content_helpers.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';

/// Loads the bundled content pack from app assets without any network access.
///
/// The bundle is the single source of truth for questions (PLAN §5.1, §7.4).
/// All parsing and validation lives in [ContentParser] (pure Dart), so this
/// loader only performs the asset fetch and surfaces diagnostics (PLAN §5.2).
class ContentLoader {
  const ContentLoader({
    this.bundle,
    this.manifestAssetPath = 'assets/content/manifest.json',
    this.contentRoot = 'assets/content',
  });

  /// Asset bundle to read from. Injectable so tests can use a fake bundle.
  /// When `null`, the app's [rootBundle] is used at load time.
  final AssetBundle? bundle;

  /// Path of the manifest inside the bundle.
  final String manifestAssetPath;

  /// Directory that holds the content files referenced by the manifest.
  final String contentRoot;

  /// Loads and validates the entire content pack.
  Future<ContentLoadResult> load() async {
    final AssetBundle assetBundle = bundle ?? rootBundle;
    final String manifestJson;
    try {
      manifestJson = await assetBundle.loadString(manifestAssetPath);
    } catch (e) {
      return const ContentLoadFailure(
        issues: <ContentIssue>[
          ContentIssue(
            severity: IssueSeverity.error,
            code: IssueCode.fileMissing,
            message: 'Could not load the content manifest from assets.',
          ),
        ],
      );
    }

    final Map<String, String> fileJsons = <String, String>{};

    // Enumerate the declared files from the manifest so we can fetch each one.
    // A broken manifest is still handed to the parser, which reports it
    // cleanly.
    try {
      final Map<String, dynamic> manifestMap = decodeObject(manifestJson);
      final List<String> files = stringList(manifestMap['files']);
      for (final String file in files) {
        try {
          fileJsons[file] = await assetBundle.loadString('$contentRoot/$file');
        } catch (_) {
          // Missing file is reported by the parser via the manifest reference.
        }
      }
    } catch (_) {
      // Parser will report the malformed manifest.
    }

    final ContentLoadResult result = ContentParser.parsePack(
      manifestJson: manifestJson,
      fileJsons: fileJsons,
    );

    for (final ContentIssue issue in result.errors) {
      AppLogger.warn('Content load issue: $issue');
    }
    return result;
  }
}
