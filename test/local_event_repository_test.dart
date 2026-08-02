import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/repositories/local_event_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalEventRepository', () {
    test('getEvents returns the seeded events', () async {
      final repository = LocalEventRepository();
      final events = await repository.getEvents();
      expect(events, isNotEmpty);
    });

    test('saveEvent adds a new event by id', () async {
      final repository = LocalEventRepository();
      final before = await repository.getEvents();

      final newEvent = DateEvent(
        id: 'new-1',
        title: 'Marathon',
        date: DateTime(2026, 10, 1),
        direction: CountDirection.until,
      );
      await repository.saveEvent(newEvent);

      final after = await repository.getEvents();
      expect(after.length, before.length + 1);
      expect(after.any((e) => e.id == 'new-1'), isTrue);
    });

    test('saveEvent overwrites an existing event with the same id', () async {
      final repository = LocalEventRepository();
      final before = await repository.getEvents();
      final existing = before.first;

      final updated = DateEvent(
        id: existing.id,
        title: 'Updated Title',
        date: existing.date,
        direction: existing.direction,
      );
      await repository.saveEvent(updated);

      final after = await repository.getEvents();
      expect(after.length, before.length);
      expect(after.firstWhere((e) => e.id == existing.id).title, 'Updated Title');
    });

    test('deleteEvent removes the event with the matching id', () async {
      final repository = LocalEventRepository();
      final before = await repository.getEvents();
      final target = before.first;

      await repository.deleteEvent(target.id);

      final after = await repository.getEvents();
      expect(after.length, before.length - 1);
      expect(after.any((e) => e.id == target.id), isFalse);
    });
  });
}
