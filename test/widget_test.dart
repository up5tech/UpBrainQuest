import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:up_brain_quest/app/app.dart';
import 'package:up_brain_quest/app/router.dart';
import 'package:up_brain_quest/core/theme/app_theme.dart';

void main() {
  testWidgets('app boots and renders the home route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(UpBrainQuestApp(router: createRouter()));

    await tester.pumpAndSettle();

    expect(find.text('UpBrainQuest'), findsOneWidget);
  });

  testWidgets('app uses the shared dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(UpBrainQuestApp(router: createRouter()));

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.text('UpBrainQuest'));
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

    await tester.pumpWidget(UpBrainQuestApp(router: createRouter()));

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
