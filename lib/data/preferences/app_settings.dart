/// Languages the app ships UI copy and question content for.
///
/// The codes must stay in sync with `supportedLocales` in
/// `assets/content/manifest.json`; a test asserts they match.
abstract final class AppLanguages {
  const AppLanguages._();

  static const String english = 'en';
  static const String vietnamese = 'vi';

  /// Every bundled language, in display order.
  static const List<String> supported = <String>[english, vietnamese];

  /// Default used until the player chooses a language.
  static const String fallback = english;

  /// Whether [code] is shipped by this build.
  static bool isSupported(String? code) =>
      code != null && supported.contains(code);

  /// Returns [code] when supported, otherwise [fallback].
  static String resolve(String? code) => isSupported(code) ? code! : fallback;
}

/// Lightweight, non-critical UI preferences (PLAN §7.1, §7.2).
///
/// These preferences are persisted locally and never represent authoritative
/// game records. Authoritative progress lives in the Drift database.
class AppSettings {
  const AppSettings({
    required this.reducedMotion,
    required this.soundEnabled,
    required this.hapticsEnabled,
    this.languageCode = AppLanguages.fallback,
  });

  final bool reducedMotion;
  final bool soundEnabled;
  final bool hapticsEnabled;

  /// BCP-47 language code for both UI copy and bundled questions.
  final String languageCode;

  AppSettings copyWith({
    bool? reducedMotion,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? languageCode,
  }) {
    return AppSettings(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
