import 'package:up_brain_quest/domain/content/content_enums.dart';

/// A single selectable choice for a multiple-choice or EQ question.
class QuestionOption {
  const QuestionOption({required this.id, required this.text});

  final String id;
  final String text;
}

/// EQ rubric entry: dimension scores plus contextual feedback for one option.
class RubricEntry {
  const RubricEntry({required this.scores, required this.feedback});

  final Map<EqDimension, int> scores;
  final String feedback;
}

/// Base contract for every bundled content item (PLAN §5.4).
///
/// Subclasses live in this same library because [QuestionItem] is `sealed`.
sealed class QuestionItem {
  const QuestionItem({
    required this.id,
    required this.domain,
    required this.contentType,
    required this.skill,
    required this.difficulty,
    required this.locale,
    required this.prompt,
    this.instructions,
    this.explanation,
    this.hint,
    this.estimatedSeconds,
    this.pointsWeight,
    required this.tags,
    this.contentVersion,
    this.attribution,
    required this.status,
  });

  final String id;
  final ContentDomain domain;
  final ContentType contentType;
  final String skill;
  final Difficulty difficulty;
  final String locale;
  final String prompt;
  final String? instructions;
  final String? explanation;
  final String? hint;
  final int? estimatedSeconds;
  final int? pointsWeight;
  final List<String> tags;
  final int? contentVersion;
  final String? attribution;
  final ContentStatus status;

  bool get isDraft => status == ContentStatus.draft;
}

/// Objective multiple-choice reasoning item (PLAN §5.4, §5.5).
class MultipleChoiceItem extends QuestionItem {
  const MultipleChoiceItem({
    required super.id,
    required super.domain,
    required super.contentType,
    required super.skill,
    required super.difficulty,
    required super.locale,
    required super.prompt,
    super.instructions,
    super.explanation,
    super.hint,
    super.estimatedSeconds,
    super.pointsWeight,
    required super.tags,
    super.contentVersion,
    super.attribution,
    required super.status,
    required this.options,
    required this.correctOptionId,
  });

  final List<QuestionOption> options;
  final String correctOptionId;
}

/// Interactive puzzle item (memory sequence, reorder, etc.) (PLAN §5.4).
class PuzzleItem extends QuestionItem {
  const PuzzleItem({
    required super.id,
    required super.domain,
    required super.contentType,
    required super.skill,
    required super.difficulty,
    required super.locale,
    required super.prompt,
    super.instructions,
    super.explanation,
    super.hint,
    super.estimatedSeconds,
    super.pointsWeight,
    required super.tags,
    super.contentVersion,
    super.attribution,
    required super.status,
    required this.expectedAnswer,
    this.options = const <QuestionOption>[],
    this.interactionConfig,
  });

  /// Correct answer: integers for `memory_sequence`, tile-id strings for
  /// `reorder_sequence`, symbol ids for `visual_pattern` and `odd_one_out`,
  /// pair ids for `matching_pairs`. Validator enforces element types per
  /// mechanic.
  final List<dynamic> expectedAnswer;

  /// Selectable symbols for the symbol-based mechanics. Always empty for
  /// `memory_sequence` and `reorder_sequence`.
  final List<QuestionOption> options;

  final Map<String, dynamic>? interactionConfig;
}

/// EQ scenario item with per-option rubric feedback (PLAN §5.4, §5.6).
class EqScenarioItem extends QuestionItem {
  const EqScenarioItem({
    required super.id,
    required super.domain,
    required super.contentType,
    required super.skill,
    required super.difficulty,
    required super.locale,
    required super.prompt,
    super.instructions,
    super.explanation,
    super.hint,
    super.estimatedSeconds,
    super.pointsWeight,
    required super.tags,
    super.contentVersion,
    super.attribution,
    required super.status,
    required this.options,
    required this.scenarioContext,
    required this.rubricByOption,
    this.skillDimensions = const <EqDimension>[],
    this.followUpReflection,
  });

  final List<QuestionOption> options;
  final String scenarioContext;
  final Map<String, RubricEntry> rubricByOption;
  final List<EqDimension> skillDimensions;
  final String? followUpReflection;
}
