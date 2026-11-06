/// Domain a question belongs to (PLAN §5.4).
enum ContentDomain { iq, puzzle, eq }

extension ContentDomainX on ContentDomain {
  static ContentDomain? tryParse(String value) => switch (value) {
    'iq' => ContentDomain.iq,
    'puzzle' => ContentDomain.puzzle,
    'eq' => ContentDomain.eq,
    _ => null,
  };
}

/// How a question is presented and answered (PLAN §5.4).
enum ContentType {
  multipleChoice,
  memorySequence,
  reorderSequence,
  scenarioChoice,
  visualPattern,
  oddOneOut,
  matchingPairs,
}

extension ContentTypeX on ContentType {
  static ContentType? tryParse(String value) => switch (value) {
    'multiple_choice' => ContentType.multipleChoice,
    'memory_sequence' => ContentType.memorySequence,
    'reorder_sequence' => ContentType.reorderSequence,
    'scenario_choice' => ContentType.scenarioChoice,
    'visual_pattern' => ContentType.visualPattern,
    'odd_one_out' => ContentType.oddOneOut,
    'matching_pairs' => ContentType.matchingPairs,
    _ => null,
  };
}

/// Authoring difficulty tier (PLAN §5.4).
enum Difficulty { easy, medium, hard }

extension DifficultyX on Difficulty {
  static Difficulty? tryParse(String value) => switch (value) {
    'easy' => Difficulty.easy,
    'medium' => Difficulty.medium,
    'hard' => Difficulty.hard,
    _ => null,
  };
}

/// EQ rubric dimensions (PLAN §4.6, §5.6).
enum EqDimension {
  emotionAwareness,
  selfRegulation,
  perspectiveTaking,
  constructiveCommunication,
  boundariesAndAgency,
}

extension EqDimensionX on EqDimension {
  static EqDimension? tryParse(String value) => switch (value) {
    'emotion_awareness' => EqDimension.emotionAwareness,
    'self_regulation' => EqDimension.selfRegulation,
    'perspective_taking' => EqDimension.perspectiveTaking,
    'constructive_communication' => EqDimension.constructiveCommunication,
    'boundaries_and_agency' => EqDimension.boundariesAndAgency,
    _ => null,
  };

  String get key => switch (this) {
    EqDimension.emotionAwareness => 'emotion_awareness',
    EqDimension.selfRegulation => 'self_regulation',
    EqDimension.perspectiveTaking => 'perspective_taking',
    EqDimension.constructiveCommunication => 'constructive_communication',
    EqDimension.boundariesAndAgency => 'boundaries_and_agency',
  };
}

/// Authoring maturity flag (PLAN Phase 2 task 6: label draft content).
enum ContentStatus { draft, finalStatus }

extension ContentStatusX on ContentStatus {
  static ContentStatus? tryParse(String value) => switch (value) {
    'draft' => ContentStatus.draft,
    'final' => ContentStatus.finalStatus,
    _ => null,
  };
}
