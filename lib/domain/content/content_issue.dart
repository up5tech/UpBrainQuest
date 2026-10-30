import 'package:up_brain_quest/domain/content/content_manifest.dart';

/// Severity of a content diagnostic (PLAN §5.8).
enum IssueSeverity { info, warning, error }

/// Stable machine-readable codes for content diagnostics.
///
/// Used by tests and developer tooling to assert on specific failure modes
/// without string-matching messages.
enum IssueCode {
  manifestInvalid,
  fileMissing,
  fileInvalid,
  itemMalformed,
  missingId,
  duplicateId,
  unknownDomain,
  unknownContentType,
  unknownDifficulty,
  missingPrompt,
  missingOptions,
  optionMissingId,
  optionMissingText,
  invalidCorrectOption,
  missingExplanation,
  missingScenarioContext,
  missingRubric,
  rubricMissingFeedback,
  rubricScoreOutOfRange,
  unknownRubricDimension,
  unexpectedUrl,
  unsupportedLocale,
  insufficientCount,
  invalidInteractionConfig,
  draftContent,
}

/// A single, understandable diagnostic produced while loading content.
///
/// Invalid records are reported here rather than crashing the app or silently
/// becoming incorrect questions (PLAN §5.2, Phase 2 acceptance).
class ContentIssue {
  const ContentIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.itemId,
  });

  final IssueSeverity severity;
  final IssueCode code;
  final String message;
  final String? itemId;

  bool get isError => severity == IssueSeverity.error;
  bool get isWarning => severity == IssueSeverity.warning;

  @override
  String toString() => '[$severity] ${code.name}: $message';
}

/// Outcome of loading the bundled content pack.
sealed class ContentLoadResult {
  const ContentLoadResult({required this.issues});

  final List<ContentIssue> issues;

  List<ContentIssue> get errors =>
      issues.where((ContentIssue i) => i.isError).toList();

  List<ContentIssue> get warnings =>
      issues.where((ContentIssue i) => i.isWarning).toList();
}

/// The pack loaded successfully; [bank] holds every valid item.
class ContentLoadSuccess extends ContentLoadResult {
  const ContentLoadSuccess({required this.bank, required super.issues});

  final ContentBank bank;
}

/// The pack could not produce any usable items (e.g. unreadable manifest or all
/// records invalid).
class ContentLoadFailure extends ContentLoadResult {
  const ContentLoadFailure({required super.issues});
}
