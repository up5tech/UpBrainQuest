import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/core/theme/app_theme.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('app boots and renders the home route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.pumpAndSettle();

    // The brand appears in both the AppBar title and the home hero card.
    expect(find.text('UpBrainQuest'), findsWidgets);
  });

  testWidgets('app uses the shared dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.text('UpBrainQuest').first,
    );
    final ThemeData theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppTheme.dark().colorScheme.primary);
  });

  testWidgets('app renders without overflow at a narrow phone width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildTestApp());

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
