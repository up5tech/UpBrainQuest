/// Achievement identifiers and rules (PLAN Phase 7).
enum AchievementId {
  firstQuest,
  fiveQuests,
  reasoningExplorer,
  reflectionExplorer,
  consistentPlayer,
}

/// Stable keys and parsing for [AchievementId].
extension AchievementIdX on AchievementId {
  /// Stable persistence/serialisation key.
  String get key => switch (this) {
    AchievementId.firstQuest => 'first_quest',
    AchievementId.fiveQuests => 'five_quests',
    AchievementId.reasoningExplorer => 'reasoning_explorer',
    AchievementId.reflectionExplorer => 'reflection_explorer',
    AchievementId.consistentPlayer => 'consistent_player',
  };

  /// Parses a persisted key, or `null` if unknown.
  static AchievementId? tryParse(String? value) => switch (value) {
    'first_quest' => AchievementId.firstQuest,
    'five_quests' => AchievementId.fiveQuests,
    'reasoning_explorer' => AchievementId.reasoningExplorer,
    'reflection_explorer' => AchievementId.reflectionExplorer,
    'consistent_player' => AchievementId.consistentPlayer,
    _ => null,
  };
}

/// A stable definition: an id and the progress target that unlocks it.
class AchievementDefinition {
  const AchievementDefinition({required this.id, required this.target});

  final AchievementId id;
  final int target;
}

/// The fixed achievement catalog (PLAN Phase 7 task 1).
abstract final class AchievementCatalog {
  const AchievementCatalog._();

  /// Version of these rules, persisted with each record.
  static const int definitionVersion = 1;

  static const List<AchievementDefinition> all = <AchievementDefinition>[
    AchievementDefinition(id: AchievementId.firstQuest, target: 1),
    AchievementDefinition(id: AchievementId.fiveQuests, target: 5),
    AchievementDefinition(id: AchievementId.reasoningExplorer, target: 3),
    AchievementDefinition(id: AchievementId.reflectionExplorer, target: 3),
    AchievementDefinition(id: AchievementId.consistentPlayer, target: 3),
  ];
}

/// Computed progress before persistence.
class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.current,
    required this.target,
  });

  final AchievementId id;
  final int current;
  final int target;

  bool get met => current >= target;

  double get fraction {
    if (target <= 0) return 1;
    final double raw = current / target;
    return raw < 0 ? 0 : (raw > 1 ? 1 : raw);
  }
}

/// Persisted achievement state, which may carry an unlock timestamp.
class AchievementRecord {
  const AchievementRecord({
    required this.id,
    required this.current,
    required this.target,
    this.unlockedAt,
  });

  final AchievementId id;
  final int current;
  final int target;
  final DateTime? unlockedAt;

  bool get unlocked => unlockedAt != null;

  bool get met => current >= target;

  double get fraction {
    if (target <= 0) return 1;
    final double raw = current / target;
    return raw < 0 ? 0 : (raw > 1 ? 1 : raw);
  }
}

/// Aggregate inputs the engine evaluates against.
class AchievementStats {
  const AchievementStats({
    required this.completedSessions,
    required this.reasoningSessions,
    required this.reflectionSessions,
    required this.longestStreak,
  });

  const AchievementStats.empty()
    : completedSessions = 0,
      reasoningSessions = 0,
      reflectionSessions = 0,
      longestStreak = 0;

  final int completedSessions;
  final int reasoningSessions;
  final int reflectionSessions;
  final int longestStreak;
}

/// Pure achievement evaluation (PLAN Phase 7 task 2).
class AchievementEngine {
  const AchievementEngine();

  List<AchievementProgress> evaluate(AchievementStats stats) {
    return <AchievementProgress>[
      for (final AchievementDefinition definition in AchievementCatalog.all)
        AchievementProgress(
          id: definition.id,
          current: _clamp(_value(definition.id, stats), definition.target),
          target: definition.target,
        ),
    ];
  }

  int _value(AchievementId id, AchievementStats stats) => switch (id) {
    AchievementId.firstQuest => stats.completedSessions,
    AchievementId.fiveQuests => stats.completedSessions,
    AchievementId.reasoningExplorer => stats.reasoningSessions,
    AchievementId.reflectionExplorer => stats.reflectionSessions,
    AchievementId.consistentPlayer => stats.longestStreak,
  };

  int _clamp(int value, int target) {
    if (value < 0) return 0;
    return value > target ? target : value;
  }
}
