import 'package:flutter_test/flutter_test.dart';

import 'package:up_brain_quest/domain/daily/daily.dart';

void main() {
  group('StreakCalculator', () {
    const StreakCalculator calculator = StreakCalculator();
    final DateTime today = DateTime(2026, 1, 10);

    test('same day counts once', () {
      final StreakSummary streak = calculator.compute(<DateTime>[
        today,
      ], today: today);
      expect(streak.current, 1);
      expect(streak.longest, 1);
    });

    test('next day extends the streak', () {
      final StreakSummary streak = calculator.compute(<DateTime>[
        DateTime(2026, 1, 9),
        DateTime(2026, 1, 10),
      ], today: today);
      expect(streak.current, 2);
      expect(streak.longest, 2);
    });

    test('missed day resets the current streak but keeps the longest', () {
      final StreakSummary streak = calculator.compute(<DateTime>[
        DateTime(2026),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 10),
      ], today: today);
      expect(streak.current, 1);
      expect(streak.longest, 3);
    });

    test('yesterday keeps the streak alive until a full day is missed', () {
      final StreakSummary streak = calculator.compute(<DateTime>[
        DateTime(2026, 1, 8),
        DateTime(2026, 1, 9),
      ], today: today);
      expect(streak.current, 2);
      expect(streak.longest, 2);
    });

    test('a two-day gap resets the current streak', () {
      final StreakSummary streak = calculator.compute(<DateTime>[
        DateTime(2026, 1, 7),
        DateTime(2026, 1, 8),
      ], today: today);
      expect(streak.current, 0);
      expect(streak.longest, 2);
    });

    test('empty activity has no streak', () {
      final StreakSummary streak = calculator.compute(
        const <DateTime>[],
        today: today,
      );
      expect(streak.current, 0);
      expect(streak.longest, 0);
    });
  });
}
