/// Game modes supported by the session engine (PLAN §2.2, §9.2).
enum GameMode {
  quickQuest,
  iqChallenge,
  eqChallenge,
  puzzleSprint,
  dailyChallenge,
}

/// Helpers for [GameMode] that do not depend on Flutter.
extension GameModeX on GameMode {
  /// Stable route/serialisation key (PLAN §9.2 — route params are never
  /// trusted as arbitrary input).
  String get key => switch (this) {
    GameMode.quickQuest => 'quick',
    GameMode.iqChallenge => 'iq',
    GameMode.eqChallenge => 'eq',
    GameMode.puzzleSprint => 'puzzle',
    GameMode.dailyChallenge => 'daily',
  };

  /// Parses a route key back into a [GameMode], or `null` if unknown.
  static GameMode? tryParse(String? value) => switch (value) {
    'quick' => GameMode.quickQuest,
    'iq' => GameMode.iqChallenge,
    'eq' => GameMode.eqChallenge,
    'puzzle' => GameMode.puzzleSprint,
    'daily' => GameMode.dailyChallenge,
    _ => null,
  };
}
