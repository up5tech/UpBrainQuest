import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/data/preferences/app_settings.dart';
import 'package:up_brain_quest/data/preferences/settings_repository.dart';

import '../support/test_app.dart';

/// In-memory [SettingsRepository] used to verify the UI toggles are persisted
/// without depending on the platform shared-preferences backend in tests.
///
/// The constructor passes a real [SharedPreferencesAsync] so the signature is
/// satisfied, but every read/write method is overridden, so the platform is
/// never touched.
class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository();

  AppSettings _state = const AppSettings(
    reducedMotion: false,
    soundEnabled: true,
    hapticsEnabled: true,
  );

  bool reducedMotionPersisted = false;

  @override
  Future<AppSettings> load() async => _state;

  @override
  Future<void> setReducedMotion(bool value) async {
    reducedMotionPersisted = true;
    _state = _state.copyWith(reducedMotion: value);
  }
}

void main() {
  testWidgets('reduced-motion toggle updates the UI and is persisted', (
    WidgetTester tester,
  ) async {
    final FakeSettingsRepository fake = FakeSettingsRepository();

    await tester.pumpWidget(buildTestApp(settingsRepository: fake));
    await tester.pumpAndSettle();

    // Navigate to Settings.
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();

    final Finder reducedMotionTile = find.ancestor(
      of: find.text(AppStrings.settingReducedMotion),
      matching: find.byType(SwitchListTile),
    );
    expect(reducedMotionTile, findsOneWidget);

    final SwitchListTile before = tester.widget<SwitchListTile>(
      reducedMotionTile,
    );
    expect(before.value, isFalse);

    await tester.tap(reducedMotionTile);
    await tester.pumpAndSettle();

    final SwitchListTile after = tester.widget<SwitchListTile>(
      reducedMotionTile,
    );
    expect(after.value, isTrue);

    // The UI change flowed through the notifier into the repository.
    expect(fake.reducedMotionPersisted, isTrue);
    expect(fake._state.reducedMotion, isTrue);
  });
}
