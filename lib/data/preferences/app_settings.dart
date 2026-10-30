/// Lightweight, non-critical UI preferences (PLAN §7.1, §7.2).
///
/// These preferences are persisted locally and never represent authoritative
/// game records. Authoritative progress lives in the Drift database.
class AppSettings {
  const AppSettings({
    required this.reducedMotion,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  final bool reducedMotion;
  final bool soundEnabled;
  final bool hapticsEnabled;

  AppSettings copyWith({
    bool? reducedMotion,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
