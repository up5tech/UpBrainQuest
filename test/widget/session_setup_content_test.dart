import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/app/providers.dart';
import 'package:up_brain_quest/core/localization/app_strings.dart';
import 'package:up_brain_quest/core/theme/app_colors.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';
import 'package:up_brain_quest/core/widgets/app_error_state.dart';
import 'package:up_brain_quest/data/content/content_loader.dart';
import 'package:up_brain_quest/domain/content/content_issue.dart';
import 'package:up_brain_quest/features/gameplay/presentation/session_setup_page.dart';

import '../support/test_app.dart';

/// English strings used by assertions (the app default locale).
final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));

/// The setup screen is where a bundle that ships the manifest but not the
/// question JSON becomes visible: every playable mode shows
/// [enStrings.sessionNoContent] instead of a start button. This loads the real
/// bundled pack so the regression cannot hide behind a fixture.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (String label, String modeKey) in <(String, String)>[
    ('Quick Quest', 'quick'),
    ('IQ Challenge', 'iq'),
    ('EQ Challenge', 'eq'),
    ('Daily Challenge', 'daily'),
  ]) {
    testWidgets('$label setup offers a start button with bundled content', (
      WidgetTester tester,
    ) async {
      final ContentLoadResult? loaded = await tester.runAsync(
        () => const ContentLoader().load(),
      );
      expect(
        loaded,
        isA<ContentLoadSuccess>(),
        reason: 'The bundled question JSON must load from the app assets.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contentProvider.overrideWith(
              (Ref ref) => Future<ContentLoadResult>.value(loaded),
            ),
          ],
          child: localizedTestApp(SessionSetupPage(modeKey: modeKey)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(enStrings.sessionNoContent), findsNothing);
      expect(find.byType(AppErrorState), findsNothing);
      expect(find.text(enStrings.sessionStart), findsOneWidget);

      // The header card sits on the violet gradient, so every string in it
      // needs the dark on-accent colour to clear WCAG AA.
      final Finder header = find.byWidgetPredicate(
        (Widget widget) => widget is AppCard && widget.gradient != null,
      );
      expect(header, findsOneWidget);
      for (final Text text in tester.widgetList<Text>(
        find.descendant(of: header, matching: find.byType(Text)),
      )) {
        expect(text.style?.color, AppColors.textOnAccent);
      }
    });
  }
}
