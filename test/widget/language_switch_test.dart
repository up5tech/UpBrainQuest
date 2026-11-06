import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/data/preferences/settings_repository.dart';

import '../support/test_app.dart';

final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));
final AppLocalizations viStrings = lookupAppLocalizations(const Locale('vi'));

/// In-memory [SettingsRepository] so the language switch can be verified
/// without the platform shared-preferences backend.
class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository();

  AppSettings _state = const AppSettings(
    reducedMotion: false,
    soundEnabled: true,
    hapticsEnabled: true,
  );

  String? persistedLanguageCode;

  @override
  Future<AppSettings> load() async => _state;

  @override
  Future<void> setLanguageCode(String code) async {
    persistedLanguageCode = code;
    _state = _state.copyWith(languageCode: code);
  }
}

void main() {
  testWidgets('language picker switches UI copy and persists the choice', (
    WidgetTester tester,
  ) async {
    final FakeSettingsRepository fake = FakeSettingsRepository();

    await tester.pumpWidget(buildTestApp(settingsRepository: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();

    expect(find.text(enStrings.settingsTitle), findsAtLeastNWidgets(1));

    await tester.tap(
      find.ancestor(
        of: find.text(enStrings.settingLanguage),
        matching: find.byType(ListTile),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(viStrings.languageVietnamese));
    await tester.pumpAndSettle();

    // The chosen language reached the repository and the whole UI follows.
    expect(fake.persistedLanguageCode, AppLanguages.vietnamese);
    expect(find.text(viStrings.settingsTitle), findsAtLeastNWidgets(1));
    expect(find.text(enStrings.settingsTitle), findsNothing);
    expect(find.text(viStrings.settingLanguage), findsOneWidget);
    expect(find.text(viStrings.navHome), findsAtLeastNWidgets(1));
  });
}
