import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:up_brain_quest/core/localization/app_strings.dart';

import '../support/test_app.dart';

/// English strings used by assertions (the app default locale).
final AppLocalizations enStrings = lookupAppLocalizations(const Locale('en'));

/// Reads the currently selected bottom-navigation index.
int _selectedIndex(WidgetTester tester) {
  final NavigationBar bar = tester.widget<NavigationBar>(
    find.byType(NavigationBar),
  );
  return bar.selectedIndex;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('all four destinations are reachable via bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // The navigation shell is present and Home is the initial destination.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(enStrings.navHome), findsOneWidget);
    expect(find.text(enStrings.navExplore), findsOneWidget);
    expect(find.text(enStrings.navProgress), findsOneWidget);
    expect(find.text(enStrings.navSettings), findsOneWidget);
    expect(_selectedIndex(tester), 0);
    expect(find.text(enStrings.homeProgressSummary), findsWidgets);

    // Explore.
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(_selectedIndex(tester), 1);

    // Progress.
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    expect(_selectedIndex(tester), 2);

    // Settings.
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();
    expect(_selectedIndex(tester), 3);

    // Back to Home.
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(_selectedIndex(tester), 0);
  });

  testWidgets('settings destination shows the preferences section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();

    expect(find.text(enStrings.settingsPreferences), findsWidgets);
  });
}
