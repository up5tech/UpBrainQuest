/// Local daily-challenge and streak rules (PLAN §2.2E, Phase 7).
///
/// Everything here is pure and date-injectable so tests can cover same-day,
/// next-day, and missed-day cases deterministically.
library;

/// Formats a device-local date as the `yyyy-MM-dd` key used by daily activity.
String localDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Local daily activity for one date.
class DailyStatus {
  const DailyStatus({
    required this.localDate,
    required this.completedDailyChallenge,
    required this.completedSessionsCount,
  });

  /// A date with no recorded activity.
  const DailyStatus.none(this.localDate)
    : completedDailyChallenge = false,
      completedSessionsCount = 0;

  final String localDate;
  final bool completedDailyChallenge;
  final int completedSessionsCount;
}

/// Current and longest local streaks.
class StreakSummary {
  const StreakSummary({required this.current, required this.longest});

  const StreakSummary.empty() : current = 0, longest = 0;

  final int current;
  final int longest;
}

/// Pure streak computation over local calendar dates.
///
/// A streak counts consecutive days with any completed session. The current
/// streak stays alive if the player has not played yet today but played
/// yesterday; it resets once a full day is missed. Device-clock changes can
/// affect local streaks — this is a convenience feature, not a verified record
/// (PLAN §2.2E, §7.3).
class StreakCalculator {
  const StreakCalculator();

  StreakSummary compute(
    Iterable<DateTime> activityDates, {
    required DateTime today,
  }) {
    final Set<int> days = <int>{
      for (final DateTime date in activityDates) _dayNumber(date),
    };
    if (days.isEmpty) return const StreakSummary.empty();

    int longest = 0;
    for (final int day in days) {
      if (days.contains(day - 1)) continue; // not the start of a run
      int run = 1;
      int next = day + 1;
      while (days.contains(next)) {
        run++;
        next++;
      }
      if (run > longest) longest = run;
    }

    final int todayNumber = _dayNumber(today);
    int? anchor;
    if (days.contains(todayNumber)) {
      anchor = todayNumber;
    } else if (days.contains(todayNumber - 1)) {
      anchor = todayNumber - 1;
    }

    int current = 0;
    if (anchor != null) {
      int day = anchor;
      while (days.contains(day)) {
        current++;
        day--;
      }
    }
    return StreakSummary(current: current, longest: longest);
  }

  int _dayNumber(DateTime date) => DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(1970)).inDays;
}

/// Deterministic Daily Challenge seed from the local date + content version
/// (PLAN §2.2E, §5.7).
///
/// Uses a stable FNV-1a hash rather than `String.hashCode`, which is not
/// guaranteed to stay stable across Dart versions. The same date and content
/// version therefore always produce the same seed and the same question set.
class DailyChallengeSelector {
  const DailyChallengeSelector();

  /// Target length of a Daily Challenge (PLAN §2.2E).
  static const int questionCount = 5;

  int seedFor({required String localDate, required String contentVersion}) {
    final String key = '$localDate|$contentVersion';
    int hash = 0x811C9DC5;
    for (final int unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
