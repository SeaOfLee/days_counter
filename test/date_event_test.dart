import 'package:days_counter/models/date_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateEvent JSON serialization', () {
    test('round-trips a since event with an emoji', () {
      final event = DateEvent(
        id: '1',
        title: 'Last Drink',
        date: DateTime(2023, 6, 19),
        direction: CountDirection.since,
        emoji: '🍺',
      );

      final restored = DateEvent.fromJson(event.toJson());

      expect(restored.id, event.id);
      expect(restored.title, event.title);
      expect(restored.date, event.date);
      expect(restored.direction, event.direction);
      expect(restored.emoji, event.emoji);
    });

    test('round-trips an until event with no emoji', () {
      final event = DateEvent(
        id: '2',
        title: 'Vacation',
        date: DateTime(2026, 8, 19),
        direction: CountDirection.until,
      );

      final restored = DateEvent.fromJson(event.toJson());

      expect(restored.direction, CountDirection.until);
      expect(restored.emoji, isNull);
    });

    test('serializes the date as a plain calendar date string', () {
      final event = DateEvent(
        id: '3',
        title: 'Anniversary',
        date: DateTime(2026, 1, 5),
        direction: CountDirection.until,
      );

      expect(event.toJson()['date'], '2026-01-05');
    });

    test('round-trips reminder time and lead days', () {
      final event = DateEvent(
        id: '4',
        title: 'Vacation',
        date: DateTime(2026, 9, 10),
        direction: CountDirection.until,
        notify: true,
        notifyMinuteOfDay: 18 * 60 + 30,
        notifyDaysBefore: const [0, 7],
      );

      final restored = DateEvent.fromJson(event.toJson());

      expect(restored.notify, isTrue);
      expect(restored.notifyMinuteOfDay, 18 * 60 + 30);
      expect(restored.notifyDaysBefore, [0, 7]);
    });

    test(
      'files written before reminder settings existed load as 9am on the day',
      () {
        final restored = DateEvent.fromJson({
          'id': '5',
          'title': 'Vacation',
          'date': '2026-09-10',
          'direction': 'until',
          'emoji': null,
          'notify': true,
        });

        expect(restored.notifyMinuteOfDay, 9 * 60);
        expect(restored.notifyDaysBefore, [0]);
      },
    );
  });
}
