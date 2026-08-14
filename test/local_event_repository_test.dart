import 'dart:io';

import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/repositories/local_event_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('days_counter_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  LocalEventRepository makeRepository() {
    return LocalEventRepository(directoryProvider: () async => tempDir);
  }

  group('LocalEventRepository', () {
    /// Saves an event so tests that need existing data don't depend on
    /// seed data — first run is intentionally empty.
    Future<DateEvent> seedOne(
      LocalEventRepository repository, {
      String id = 'seed-1',
    }) async {
      final event = DateEvent(
        id: id,
        title: 'Seeded Event',
        date: DateTime(2026, 3, 4),
        direction: CountDirection.since,
      );
      await repository.saveEvent(event);
      return event;
    }

    test('getEvents returns an empty list on first run', () async {
      final events = await makeRepository().getEvents();
      expect(events, isEmpty);
    });

    test('saveEvent adds a new event by id', () async {
      final repository = makeRepository();
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
      final repository = makeRepository();
      final existing = await seedOne(repository);
      final before = await repository.getEvents();

      final updated = DateEvent(
        id: existing.id,
        title: 'Updated Title',
        date: existing.date,
        direction: existing.direction,
      );
      await repository.saveEvent(updated);

      final after = await repository.getEvents();
      expect(after.length, before.length);
      expect(
        after.firstWhere((e) => e.id == existing.id).title,
        'Updated Title',
      );
    });

    test('deleteEvent removes the event with the matching id', () async {
      final repository = makeRepository();
      final target = await seedOne(repository);
      final before = await repository.getEvents();

      await repository.deleteEvent(target.id);

      final after = await repository.getEvents();
      expect(after.length, before.length - 1);
      expect(after.any((e) => e.id == target.id), isFalse);
    });

    test('events survive a simulated app restart', () async {
      final firstRun = makeRepository();
      await firstRun.saveEvent(
        DateEvent(
          id: 'persisted-1',
          title: 'Persisted Event',
          date: DateTime(2026, 1, 1),
          direction: CountDirection.since,
        ),
      );

      // A fresh repository instance, as a new app launch would create.
      final secondRun = makeRepository();
      final events = await secondRun.getEvents();

      expect(events.any((e) => e.id == 'persisted-1'), isTrue);
    });
  });
}
