import 'package:days_counter/utils/date_calculations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('differenceInCalendarDays', () {
    test('same date is 0', () {
      final date = DateTime(2026, 8, 1);
      expect(differenceInCalendarDays(date, date), 0);
    });

    test('yesterday to today is 1', () {
      expect(
        differenceInCalendarDays(DateTime(2026, 7, 31), DateTime(2026, 8, 1)),
        1,
      );
    });

    test('today to tomorrow is 1', () {
      expect(
        differenceInCalendarDays(DateTime(2026, 8, 1), DateTime(2026, 8, 2)),
        1,
      );
    });

    test('ignores time of day', () {
      final morning = DateTime(2026, 8, 1, 6, 0);
      final night = DateTime(2026, 8, 1, 23, 59);
      expect(differenceInCalendarDays(morning, night), 0);
    });

    test('year-end rollover: Dec 31 to Jan 1 is 1', () {
      expect(
        differenceInCalendarDays(
          DateTime(2025, 12, 31),
          DateTime(2026, 1, 1),
        ),
        1,
      );
    });

    test('leap year: Feb 28 to Feb 29 is 1 in a leap year', () {
      expect(
        differenceInCalendarDays(DateTime(2024, 2, 28), DateTime(2024, 2, 29)),
        1,
      );
    });

    test('leap year: Feb 28 to Mar 1 is 1 in a non-leap year', () {
      expect(
        differenceInCalendarDays(DateTime(2025, 2, 28), DateTime(2025, 3, 1)),
        1,
      );
    });

    test('leap year: Jan 1 to Mar 1 spans one extra day in a leap year', () {
      final leapYearSpan = differenceInCalendarDays(
        DateTime(2024, 1, 1),
        DateTime(2024, 3, 1),
      );
      final nonLeapYearSpan = differenceInCalendarDays(
        DateTime(2025, 1, 1),
        DateTime(2025, 3, 1),
      );
      expect(leapYearSpan, nonLeapYearSpan + 1);
    });

    test('DST spring-forward day still counts as exactly 1 day', () {
      // US DST began 2026-03-08; local midnight-to-midnight is only a
      // 23-hour span, which must not truncate to 0 days.
      expect(
        differenceInCalendarDays(DateTime(2026, 3, 8), DateTime(2026, 3, 9)),
        1,
      );
    });

    test('DST fall-back day still counts as exactly 1 day', () {
      // US DST ended 2026-11-01; local midnight-to-midnight is a 25-hour
      // span, which must not round up to 2 days.
      expect(
        differenceInCalendarDays(DateTime(2026, 11, 1), DateTime(2026, 11, 2)),
        1,
      );
    });

    test('cross-month span', () {
      expect(
        differenceInCalendarDays(DateTime(2026, 1, 15), DateTime(2026, 2, 15)),
        31,
      );
    });

    test('cross-year span', () {
      expect(
        differenceInCalendarDays(DateTime(2025, 6, 19), DateTime(2026, 6, 19)),
        365,
      );
    });

    test('negative when second date precedes first', () {
      expect(
        differenceInCalendarDays(DateTime(2026, 8, 1), DateTime(2026, 7, 31)),
        -1,
      );
    });
  });

  group('daysSince / daysUntil', () {
    test('daysSince counts from date to now', () {
      final now = DateTime(2026, 8, 1);
      expect(daysSince(DateTime(2023, 6, 19), now: now), 1139);
    });

    test('daysUntil counts from now to date', () {
      final now = DateTime(2026, 8, 1);
      expect(daysUntil(DateTime(2026, 8, 19), now: now), 18);
    });
  });

  group('formatDayCount', () {
    test('adds thousands separators', () {
      expect(formatDayCount(1139), '1,139');
    });

    test('leaves small numbers unchanged', () {
      expect(formatDayCount(0), '0');
      expect(formatDayCount(247), '247');
    });

    test('handles exact thousands', () {
      expect(formatDayCount(1000), '1,000');
      expect(formatDayCount(1000000), '1,000,000');
    });

    test('handles negative numbers', () {
      expect(formatDayCount(-1139), '-1,139');
    });
  });

  group('dayCountLabel', () {
    test('singular for 1 day', () {
      expect(dayCountLabel(1), '1 day');
    });

    test('plural for 0 and other counts', () {
      expect(dayCountLabel(0), '0 days');
      expect(dayCountLabel(247), '247 days');
      expect(dayCountLabel(1139), '1,139 days');
    });
  });
}
