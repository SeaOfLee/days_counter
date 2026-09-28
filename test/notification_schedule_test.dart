import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/services/notification_schedule.dart';

final _now = DateTime(2026, 8, 22, 7, 0);

DateEvent event({
  required String id,
  required DateTime date,
  CountDirection direction = CountDirection.until,
  bool notify = true,
  String title = 'Vacation',
  String? emoji,
  int notifyMinuteOfDay = DateEvent.defaultNotifyMinuteOfDay,
  List<int> notifyDaysBefore = const [0],
}) {
  return DateEvent(
    id: id,
    title: title,
    date: date,
    direction: direction,
    emoji: emoji,
    notify: notify,
    notifyMinuteOfDay: notifyMinuteOfDay,
    notifyDaysBefore: notifyDaysBefore,
  );
}

void main() {
  group('countdowns', () {
    test('an opted-in countdown is told on the day at 9am by default', () {
      final scheduled = plannedNotifications([
        event(id: 'a', emoji: '🏖', date: DateTime(2026, 8, 29)),
      ], now: _now);

      expect(scheduled, hasLength(1));
      expect(scheduled.single.id, 'a-0');
      expect(scheduled.single.title, '🏖 Vacation');
      expect(scheduled.single.body, "Today's the day.");
      expect(scheduled.single.fireDate, DateTime(2026, 8, 29, 9));
    });

    test('fires at the chosen time of day', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2026, 8, 29),
          notifyMinuteOfDay: 18 * 60 + 30,
        ),
      ], now: _now);

      expect(scheduled.single.fireDate, DateTime(2026, 8, 29, 18, 30));
    });

    test('each chosen lead time is its own reminder', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2026, 9, 10),
          notifyDaysBefore: const [0, 1, 7],
        ),
      ], now: _now);

      expect(scheduled.map((n) => n.id), ['a-7', 'a-1', 'a-0']);
      expect(scheduled.map((n) => n.fireDate), [
        DateTime(2026, 9, 3, 9),
        DateTime(2026, 9, 9, 9),
        DateTime(2026, 9, 10, 9),
      ]);
      expect(scheduled.map((n) => n.body), [
        '7 days to go.',
        'Tomorrow.',
        "Today's the day.",
      ]);
    });

    test('a lead time already behind us is skipped, not fired late', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2026, 8, 25),
          notifyDaysBefore: const [0, 7],
        ),
      ], now: _now);

      expect(scheduled.map((n) => n.id), ['a-0']);
    });

    test('lead days cross a month boundary by calendar, not duration', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2026, 11, 3),
          notifyDaysBefore: const [7],
        ),
      ], now: _now);

      // US DST ends Nov 1, 2026: a Duration would land at 8am or 10am.
      expect(scheduled.single.fireDate, DateTime(2026, 10, 27, 9));
    });

    test('nothing is scheduled once the time on the day has gone by', () {
      final scheduled = plannedNotifications([
        event(id: 'a', date: DateTime(2026, 8, 22)),
      ], now: DateTime(2026, 8, 22, 11, 0));

      expect(scheduled, isEmpty);
    });

    test('the day itself still counts before the time', () {
      final scheduled = plannedNotifications([
        event(id: 'a', date: DateTime(2026, 8, 22)),
      ], now: DateTime(2026, 8, 22, 7, 0));

      expect(scheduled, hasLength(1));
    });

    test('events that have not opted in are skipped', () {
      final scheduled = plannedNotifications([
        event(id: 'a', date: DateTime(2026, 8, 29), notify: false),
      ], now: _now);

      expect(scheduled, isEmpty);
    });
  });

  group('count-ups', () {
    test('announce the next few milestones', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          title: 'New Job',
          date: DateTime(2026, 8, 1),
          direction: CountDirection.since,
        ),
      ], now: _now);

      // Day 21 today: next are 30, 60, 100.
      expect(scheduled.map((n) => n.id), ['a-30', 'a-60', 'a-100']);
      expect(scheduled.first.fireDate, DateTime(2026, 8, 31, 9));
      expect(scheduled.first.title, 'New Job');
      expect(scheduled.first.body, '30 days today.');
    });

    test('long-running counts land on hundreds', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2023, 6, 19),
          direction: CountDirection.since,
        ),
      ], now: _now);

      // Day 1,160 today.
      expect(scheduled.map((n) => n.id), ['a-1200', 'a-1300', 'a-1400']);
      expect(scheduled.first.body, '1,200 days today.');
    });

    test("today's milestone counts until its time passes", () {
      final date = DateTime(2026, 5, 14); // Day 100 on Aug 22.

      expect(
        plannedNotifications([
          event(id: 'a', date: date, direction: CountDirection.since),
        ], now: DateTime(2026, 8, 22, 7)).first.id,
        'a-100',
      );
      expect(
        plannedNotifications([
          event(id: 'a', date: date, direction: CountDirection.since),
        ], now: DateTime(2026, 8, 22, 10)).first.id,
        'a-200',
      );
    });
  });

  group('isNotificationMilestone', () {
    test('30, 60, then every hundred', () {
      for (final days in [30, 60, 100, 200, 1000, 1500]) {
        expect(isNotificationMilestone(days), isTrue, reason: '$days');
      }
    });

    test('nothing else, and never zero or negatives', () {
      for (final days in [0, -100, 7, 29, 31, 90, 150, 365, 1050]) {
        expect(isNotificationMilestone(days), isFalse, reason: '$days');
      }
    });
  });

  group('identifiers', () {
    test('are stable so a reschedule replaces rather than duplicates', () {
      final events = [
        event(id: 'a', date: DateTime(2026, 8, 29)),
        event(
          id: 'b',
          date: DateTime(2023, 6, 19),
          direction: CountDirection.since,
        ),
      ];

      expect(
        plannedNotifications(events, now: _now).map((n) => n.id),
        plannedNotifications(events, now: _now).map((n) => n.id),
      );
    });
  });

  group('ordering and budget', () {
    test('soonest first', () {
      final scheduled = plannedNotifications([
        event(id: 'far', date: DateTime(2026, 12, 1)),
        event(id: 'soon', date: DateTime(2026, 8, 29)),
      ], now: _now);

      expect(scheduled.map((n) => n.id), ['soon-0', 'far-0']);
    });

    test('never exceeds what iOS will hold', () {
      final events = [
        for (var i = 0; i < 40; i++)
          event(
            id: 'e$i',
            date: DateTime(2026, 9, 10 + i),
            notifyDaysBefore: const [0, 1, 7],
          ),
        for (var i = 0; i < 40; i++)
          event(
            id: 's$i',
            date: DateTime(2025, 1, 1 + i),
            direction: CountDirection.since,
          ),
      ];

      expect(
        plannedNotifications(events, now: _now),
        hasLength(maxPendingNotifications),
      );
    });
  });

  group('serialization', () {
    test('sends date components, not an instant', () {
      final scheduled = plannedNotifications([
        event(
          id: 'a',
          date: DateTime(2026, 8, 29),
          notifyMinuteOfDay: 7 * 60 + 15,
        ),
      ], now: DateTime(2026, 8, 22, 7, 0));

      expect(scheduled.single.toJson(), {
        'id': 'a-0',
        'title': 'Vacation',
        'body': "Today's the day.",
        'year': 2026,
        'month': 8,
        'day': 29,
        'hour': 7,
        'minute': 15,
      });
    });
  });
}
