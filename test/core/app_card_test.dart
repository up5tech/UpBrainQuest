import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/theme/app_gradients.dart';
import 'package:up_brain_quest/core/widgets/app_card.dart';

import '../support/test_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('a nested tile can paint its background and ink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedTestApp(
          const Scaffold(
            body: AppCard(
              child: ExpansionTile(
                title: Text('Hint'),
                children: <Widget>[Text('Look again.')],
              ),
            ),
          ),
        ),
      );

      // Without a Material surface the card's opaque Container hides the
      // ExpansionTile's ListTile background and ink, and Flutter reports it.
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();
      expect(find.text('Look again.'), findsOneWidget);
    });

    testWidgets('a tappable gradient card reports taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        localizedTestApp(
          Scaffold(
            body: AppCard(
              gradient: AppGradients.primary,
              onTap: () => taps += 1,
              child: const Text('Start'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Start'));
      expect(taps, 1);
    });
  });
}
