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
  });
}
