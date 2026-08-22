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
}) {
  return DateEvent(
    id: id,
    title: title,
    date: date,
    direction: direction,
    emoji: emoji,
    notify: notify,
  );
}

void main() {
  group('what gets scheduled', () {
    test('a countdown that has opted in is told on the day', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', emoji: '🏖', date: DateTime(2026, 8, 29))],
        now: _now,
      );

      expect(scheduled, hasLength(1));
      expect(scheduled.single.id, 'a-0');
      expect(scheduled.single.title, '🏖 Vacation');
      expect(scheduled.single.body, "Today's the day.");
      expect(scheduled.single.fireDate, DateTime(2026, 8, 29, 9));
    });

    test('events that have not opted in are skipped', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 29), notify: false)],
        now: _now,
      );

      expect(scheduled, isEmpty);
    });

    test('a count-up event has no arrival to announce', () {
      final scheduled = plannedNotifications(
        [
          event(
            id: 'a',
            date: DateTime(2023, 6, 19),
            direction: CountDirection.since,
          ),
        ],
        now: _now,
      );

      expect(scheduled, isEmpty);
    });

    test('nothing is scheduled once 9am on the day has gone by', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 22))],
        now: DateTime(2026, 8, 22, 11, 0),
      );

      expect(scheduled, isEmpty);
    });

    test('the day itself still counts before 9am', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 22))],
        now: DateTime(2026, 8, 22, 7, 0),
      );

      expect(scheduled, hasLength(1));
    });

    test('a date already past is never scheduled', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 1))],
        now: _now,
      );

      expect(scheduled, isEmpty);
    });
  });

  group('identifiers', () {
    test('carry the day count so later rules can be added alongside', () {
      final scheduled = plannedNotifications(
        [event(id: 'abc', date: DateTime(2026, 8, 29))],
        now: _now,
      );

      expect(scheduled.single.id, 'abc-0');
    });

    test('are stable so a reschedule replaces rather than duplicates', () {
      final events = [event(id: 'a', date: DateTime(2026, 8, 29))];

      expect(
        plannedNotifications(events, now: _now).map((n) => n.id),
        plannedNotifications(events, now: _now).map((n) => n.id),
      );
    });
  });

  group('ordering and budget', () {
    test('soonest first', () {
      final scheduled = plannedNotifications(
        [
          event(id: 'far', date: DateTime(2026, 12, 1)),
          event(id: 'soon', date: DateTime(2026, 8, 29)),
        ],
        now: _now,
      );

      expect(scheduled.map((n) => n.id), ['soon-0', 'far-0']);
    });

    test('never exceeds what iOS will hold', () {
      final events = [
        for (var i = 0; i < 80; i++)
          event(id: 'e$i', date: DateTime(2026, 9, 1 + i)),
      ];

      expect(
        plannedNotifications(events, now: _now),
        hasLength(maxPendingNotifications),
      );
    });
  });

  group('canNotifyFor', () {
    test('true only while the date is still ahead', () {
      expect(canNotifyFor(DateTime(2026, 8, 29), now: _now), isTrue);
      expect(canNotifyFor(DateTime(2026, 8, 23), now: _now), isTrue);
    });

    test('false for today and for anything past', () {
      expect(canNotifyFor(DateTime(2026, 8, 22), now: _now), isFalse);
      expect(canNotifyFor(DateTime(2026, 8, 21), now: _now), isFalse);
      expect(canNotifyFor(DateTime(2023, 6, 19), now: _now), isFalse);
    });
  });

  group('serialization', () {
    test('sends date components, not an instant', () {
      final scheduled = plannedNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 29))],
        now: _now,
      );

      expect(scheduled.single.toJson(), {
        'id': 'a-0',
        'title': 'Vacation',
        'body': "Today's the day.",
        'year': 2026,
        'month': 8,
        'day': 29,
        'hour': 9,
        'minute': 0,
      });
    });
  });
}
