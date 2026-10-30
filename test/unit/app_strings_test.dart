import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('exposes non-empty navigation labels', () {
      expect(AppStrings.navHome, isNotEmpty);
      expect(AppStrings.navExplore, isNotEmpty);
      expect(AppStrings.navProgress, isNotEmpty);
      expect(AppStrings.navSettings, isNotEmpty);
    });

    test('exposes the score disclaimer copy from PLAN §4.1', () {
      expect(AppStrings.aboutDisclaimer, contains('not standardized IQ'));
      expect(AppStrings.aboutDisclaimer, contains('clinical EQ'));
    });

    test('keeps every mode name and description populated', () {
      expect(AppStrings.modeQuickQuestDesc, isNotEmpty);
      expect(AppStrings.modeIqChallengeDesc, isNotEmpty);
      expect(AppStrings.modePuzzleSprintDesc, isNotEmpty);
      expect(AppStrings.modeEqChallengeDesc, isNotEmpty);
    });
  });
}
