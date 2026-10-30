import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  for (final double scale in <double>[1.5, 2.0]) {
    testWidgets('app has no overflow at ${scale}x text scale', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Visit every bottom-navigation destination at this scale.
      for (int i = 1; i < 4; i++) {
        await tester.tap(find.byType(NavigationDestination).at(i));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'destination $i at ${scale}x',
        );
      }
    });
  }
}
