import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/services/notification_schedule.dart';

final _now = DateTime(2026, 8, 22, 7, 0);

DateEvent event({
  required String id,
  required DateTime date,
  CountDirection direction = CountDirection.since,
  bool notify = true,
  String title = 'Last Drink',
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
  group('opting in', () {
    test('events that have not opted in are skipped', () {
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 1), notify: false)],
        now: _now,
      );

      expect(scheduled, isEmpty);
    });

    test('an opted-in event gets its next milestones', () {
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 1))],
        now: _now,
      );

      // 21 days elapsed, so 30 and 100 are next.
      expect(scheduled.map((n) => n.id), ['a-30', 'a-100']);
    });
  });

  group('identifiers', () {
    test('are stable so a reschedule replaces rather than duplicates', () {
      final events = [event(id: 'a', date: DateTime(2026, 8, 1))];

      final first = milestoneNotifications(events, now: _now);
      final second = milestoneNotifications(events, now: _now);

      expect(first.map((n) => n.id), second.map((n) => n.id));
    });
  });

  group('what the notification says', () {
    test('a countdown arriving reads as the day itself', () {
      final scheduled = milestoneNotifications(
        [
          event(
            id: 'a',
            title: 'Vacation',
            emoji: '🏖',
            date: DateTime(2026, 8, 26),
            direction: CountDirection.until,
          ),
        ],
        now: _now,
      );

      final arrival = scheduled.firstWhere((n) => n.id == 'a-0');
      expect(arrival.title, '🏖 Vacation');
      expect(arrival.body, "Today's the day.");
      expect(arrival.fireDate, DateTime(2026, 8, 26, 9));
    });

    test('a countdown short of arrival counts down', () {
      final scheduled = milestoneNotifications(
        [
          event(
            id: 'a',
            date: DateTime(2026, 10, 1),
            direction: CountDirection.until,
          ),
        ],
        now: _now,
      );

      expect(scheduled.first.body, '30 days to go.');
    });

    test('a rising count reads as a total', () {
      // 999 days elapsed, so the 1,000th is tomorrow. An event sitting on
      // 1,000 exactly would look past it — today's milestone is the widget's
      // and the card's job, not a future notification's.
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2023, 11, 27))],
        now: _now,
      );

      expect(scheduled.first.body, '1,000 days today.');
      expect(scheduled.first.fireDate, DateTime(2026, 8, 23, 9));
    });

    test("today's own milestone is not rescheduled as a future one", () {
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2023, 11, 26))],
        now: _now,
      );

      expect(scheduled.map((n) => n.id), ['a-1500', 'a-2000']);
    });
  });

  group('timing', () {
    test('fires at 9am local', () {
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 1))],
        now: _now,
      );

      expect(scheduled.every((n) => n.fireDate.hour == notificationHour), isTrue);
    });

    test('a milestone earlier today is not scheduled in the past', () {
      // 30 days elapsed exactly, so today is the milestone — but 9am has
      // already gone by at this hour.
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2026, 7, 23))],
        now: DateTime(2026, 8, 22, 11, 0),
      );

      expect(scheduled.any((n) => n.id == 'a-30'), isFalse);
      expect(scheduled.every((n) => n.fireDate.isAfter(DateTime(2026, 8, 22, 11))), isTrue);
    });

    test('soonest first', () {
      final scheduled = milestoneNotifications(
        [
          event(id: 'far', date: DateTime(2026, 8, 20)),
          event(id: 'soon', date: DateTime(2026, 8, 16)),
        ],
        now: _now,
      );

      for (var i = 1; i < scheduled.length; i++) {
        expect(
          scheduled[i].fireDate.isBefore(scheduled[i - 1].fireDate),
          isFalse,
        );
      }
    });
  });

  group('the pending budget', () {
    test('never exceeds what iOS will hold', () {
      final events = [
        for (var i = 0; i < 80; i++)
          event(id: 'e$i', date: DateTime(2026, 8, 1).add(Duration(days: i % 5))),
      ];

      final scheduled = milestoneNotifications(events, now: _now);

      expect(scheduled.length, lessThanOrEqualTo(maxPendingNotifications));
    });
  });

  group('serialization', () {
    test('sends date components, not an instant', () {
      final scheduled = milestoneNotifications(
        [event(id: 'a', date: DateTime(2026, 8, 1))],
        now: _now,
      );

      expect(scheduled.first.toJson(), {
        'id': 'a-30',
        'title': 'Last Drink',
        'body': '30 days today.',
        'year': 2026,
        'month': 8,
        'day': 31,
        'hour': 9,
        'minute': 0,
      });
    });
  });
}
