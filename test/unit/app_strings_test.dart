import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

  group('AppStrings (en)', () {
    test('exposes non-empty navigation labels', () {
      expect(en.navHome, isNotEmpty);
      expect(en.navExplore, isNotEmpty);
      expect(en.navProgress, isNotEmpty);
      expect(en.navSettings, isNotEmpty);
    });

    test('exposes the score disclaimer copy from PLAN §4.1', () {
      expect(en.aboutDisclaimer, contains('not standardized IQ'));
      expect(en.aboutDisclaimer, contains('clinical EQ'));
    });

    test('keeps every mode name and description populated', () {
      expect(en.modeQuickQuestDesc, isNotEmpty);
      expect(en.modeIqChallengeDesc, isNotEmpty);
      expect(en.modePuzzleSprintDesc, isNotEmpty);
      expect(en.modeEqChallengeDesc, isNotEmpty);
      expect(en.modeDailyChallengeDesc, isNotEmpty);
    });
  });
}
