import 'package:up_brain_quest/data/content/content_loader.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/domain/content/content_parser.dart';

/// Repository boundary for reading the bundled question pack.
///
/// Wraps [ContentLoader] so the rest of the app talks to a repository interface
/// rather than an asset loader directly (PLAN §6.3). The loader performs the
/// asset fetch; all parsing and validation stays in [ContentParser] (pure
/// Dart).
class ContentRepository {
  const ContentRepository([this.loader = const ContentLoader()]);

  /// Injectable loader (tests can pass a fake bundle-backed loader).
  final ContentLoader loader;

  /// Loads and validates the entire bundled content pack.
  Future<ContentLoadResult> load() => loader.load();
}
