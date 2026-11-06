import 'package:shared_preferences/shared_preferences.dart';

import 'package:up_brain_quest/data/preferences/app_settings.dart';

/// Persistence keys for local preferences.
abstract final class SettingsKeys {
  const SettingsKeys._();

  static const String reducedMotion = 'settings.reducedMotion';
  static const String soundEnabled = 'settings.soundEnabled';
  static const String hapticsEnabled = 'settings.hapticsEnabled';
  static const String languageCode = 'settings.languageCode';
}

/// Reads and writes lightweight UI preferences.
///
/// Uses [SharedPreferencesAsync] (PLAN §6.2). Authoritative session and score
/// data is never stored here (PLAN §7.1).
class SettingsRepository {
  SettingsRepository([SharedPreferencesAsync? preferences])
    : _provided = preferences;

  /// Client supplied at construction, if any. Tests inject a fake repository
  /// instead of depending on the platform implementation.
  final SharedPreferencesAsync? _provided;

  late final SharedPreferencesAsync _preferences =
      _provided ?? SharedPreferencesAsync();

  Future<AppSettings> load() async {
    final bool reducedMotion =
        await _preferences.getBool(SettingsKeys.reducedMotion) ?? false;
    final bool soundEnabled =
        await _preferences.getBool(SettingsKeys.soundEnabled) ?? true;
    final bool hapticsEnabled =
        await _preferences.getBool(SettingsKeys.hapticsEnabled) ?? true;
    // A code saved by a build that shipped another language, or a corrupt
    // value, falls back to English instead of showing an empty screen.
    final String languageCode = AppLanguages.resolve(
      await _preferences.getString(SettingsKeys.languageCode),
    );
    return AppSettings(
      reducedMotion: reducedMotion,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      languageCode: languageCode,
    );
  }

  Future<void> setReducedMotion(bool value) async {
    await _preferences.setBool(SettingsKeys.reducedMotion, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    await _preferences.setBool(SettingsKeys.soundEnabled, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    await _preferences.setBool(SettingsKeys.hapticsEnabled, value);
  }

  /// Stores [languageCode]; unsupported codes are ignored.
  Future<void> setLanguageCode(String languageCode) async {
    if (!AppLanguages.isSupported(languageCode)) return;
    await _preferences.setString(SettingsKeys.languageCode, languageCode);
  }
}
