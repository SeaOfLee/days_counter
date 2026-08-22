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

  group('dateOffsetBy', () {
    test('counts forwards', () {
      expect(
        dateOffsetBy(100, now: DateTime(2026, 8, 15)),
        DateTime(2026, 11, 23),
      );
    });

    test('counts backwards for a negative offset', () {
      expect(
        dateOffsetBy(-100, now: DateTime(2026, 8, 15)),
        DateTime(2026, 5, 7),
      );
    });

    test('zero is today', () {
      expect(
        dateOffsetBy(0, now: DateTime(2026, 8, 15, 13, 45)),
        DateTime(2026, 8, 15),
      );
    });

    test('rolls over a month boundary', () {
      expect(dateOffsetBy(1, now: DateTime(2026, 1, 31)), DateTime(2026, 2, 1));
    });

    test('rolls over a year boundary', () {
      expect(dateOffsetBy(1, now: DateTime(2026, 12, 31)), DateTime(2027, 1, 1));
    });

    test('handles a leap day', () {
      expect(dateOffsetBy(1, now: DateTime(2028, 2, 28)), DateTime(2028, 2, 29));
    });

    test('crossing DST lands on the intended calendar date', () {
      // US DST began 2026-03-08. Adding a Duration of 1 day to local
      // midnight here yields 2026-03-08 23:00 the previous day in some
      // zones; overflowing the day field cannot drift like that.
      expect(dateOffsetBy(1, now: DateTime(2026, 3, 7)), DateTime(2026, 3, 8));
      expect(dateOffsetBy(1, now: DateTime(2026, 10, 31)), DateTime(2026, 11, 1));
    });

    test('round-trips with daysUntil', () {
      final now = DateTime(2026, 8, 15);
      final target = dateOffsetBy(100, now: now);
      expect(daysUntil(target, now: now), 100);
    });

    test('round-trips with daysSince', () {
      final now = DateTime(2026, 8, 15);
      final target = dateOffsetBy(-100, now: now);
      expect(daysSince(target, now: now), 100);
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

  group('milestoneFor', () {
    test('day zero is its own kind of moment', () {
      expect(milestoneFor(0), Milestone.today);
    });

    test('recognises the early milestones', () {
      expect(milestoneFor(7), Milestone.round);
      expect(milestoneFor(30), Milestone.round);
      expect(milestoneFor(100), Milestone.round);
      expect(milestoneFor(365), Milestone.round);
    });

    test('recognises every multiple of the interval past them', () {
      expect(milestoneFor(500), Milestone.round);
      expect(milestoneFor(1000), Milestone.round);
      expect(milestoneFor(1500), Milestone.round);
      expect(milestoneFor(10000), Milestone.round);
    });

    test('ordinary days are not milestones', () {
      expect(milestoneFor(1), isNull);
      expect(milestoneFor(247), isNull);
      expect(milestoneFor(1139), isNull);
    });

    test('the days either side of a milestone are not milestones', () {
      expect(milestoneFor(6), isNull);
      expect(milestoneFor(8), isNull);
      expect(milestoneFor(99), isNull);
      expect(milestoneFor(101), isNull);
      expect(milestoneFor(364), isNull);
      expect(milestoneFor(366), isNull);
      expect(milestoneFor(499), isNull);
      expect(milestoneFor(501), isNull);
    });

    test('yearly anniversaries past the first are not milestones', () {
      // Deliberate: only 365 is fixed, and 730 is not a multiple of 500.
      expect(milestoneFor(730), isNull);
      expect(milestoneFor(1095), isNull);
    });

    // An `until` event whose date has passed renders a negative count until
    // it is next saved, and -500 would otherwise satisfy the interval rule.
    test('negative counts never match', () {
      expect(milestoneFor(-1), isNull);
      expect(milestoneFor(-100), isNull);
      expect(milestoneFor(-500), isNull);
      expect(milestoneFor(-1000), isNull);
    });
  });

  group('upcomingMilestoneCounts counting up', () {
    List<int> up(int days, {int limit = 2}) =>
        upcomingMilestoneCounts(days, countingDown: false, limit: limit);

    test('picks the early milestones first', () {
      expect(up(0), [7, 30]);
      expect(up(8), [30, 100]);
      expect(up(101), [365, 500]);
    });

    test('falls back to the interval past the early ones', () {
      expect(up(500), [1000, 1500]);
      expect(up(1139), [1500, 2000]);
    });

    test('a day that is itself a milestone looks past it', () {
      expect(up(365), [500, 1000]);
    });

    test('honours the limit', () {
      expect(up(0, limit: 1), [7]);
      expect(up(0, limit: 4), [7, 30, 100, 365]);
    });
  });

  group('upcomingMilestoneCounts counting down', () {
    List<int> down(int days, {int limit = 2}) =>
        upcomingMilestoneCounts(days, countingDown: true, limit: limit);

    test('counts down toward arrival', () {
      expect(down(45), [30, 7]);
      expect(down(8), [7, 0]);
    });

    test('arrival day is always the last one', () {
      expect(down(5), [0]);
      expect(down(1), [0]);
    });

    test('uses the interval while the count is large', () {
      expect(down(1200), [1000, 500]);
    });

    test('nothing left once the date has arrived or passed', () {
      expect(down(0), isEmpty);
      expect(down(-5), isEmpty);
    });
  });

  group('dateOfMilestone', () {
    test('a rising count reaches N days after the event', () {
      expect(
        dateOfMilestone(DateTime(2023, 6, 19), 100, countingDown: false),
        DateTime(2023, 9, 27),
      );
    });

    test('a falling count reaches N days before the event', () {
      expect(
        dateOfMilestone(DateTime(2026, 9, 1), 30, countingDown: true),
        DateTime(2026, 8, 2),
      );
    });

    test('arrival day is the event date itself', () {
      expect(
        dateOfMilestone(DateTime(2026, 9, 1), 0, countingDown: true),
        DateTime(2026, 9, 1),
      );
    });

    test('crosses a DST boundary without drifting', () {
      // US DST starts 2026-03-08; a Duration would land an hour off.
      final result = dateOfMilestone(DateTime(2026, 3, 1), 14, countingDown: false);
      expect(result, DateTime(2026, 3, 15));
      expect(result.hour, 0);
    });

    test('rolls over a year boundary', () {
      expect(
        dateOfMilestone(DateTime(2025, 12, 20), 30, countingDown: false),
        DateTime(2026, 1, 19),
      );
    });
  });
}
