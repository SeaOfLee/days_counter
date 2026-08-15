import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/repositories/event_repository.dart';

/// A synchronous, in-memory stand-in for [EventRepository] used by widget
/// tests so they don't depend on real file I/O (which the FakeAsync zone
/// `testWidgets` runs in cannot resolve).
class InMemoryEventRepository implements EventRepository {
  // Copies the seed into a growable list: callers may pass a const literal,
  // and saveEvent/deleteEvent mutate this in place.
  InMemoryEventRepository({List<DateEvent>? seed})
    : _events = [...(seed ?? _defaultSeed())];

  final List<DateEvent> _events;

  static List<DateEvent> _defaultSeed() => [
    DateEvent(
      id: '1',
      title: 'Last Drink',
      date: DateTime(2023, 6, 19),
      direction: CountDirection.since,
      emoji: '🍺',
    ),
    DateEvent(
      id: '2',
      title: 'Started New Job',
      date: DateTime(2025, 12, 6),
      direction: CountDirection.since,
      emoji: '💼',
    ),
    DateEvent(
      id: '3',
      title: 'Vacation',
      date: DateTime(2026, 8, 19),
      direction: CountDirection.until,
      emoji: '✈️',
    ),
    DateEvent(
      id: '4',
      title: 'Anniversary',
      date: DateTime(2026, 9, 12),
      direction: CountDirection.until,
      emoji: '💍',
    ),
  ];

  @override
  Future<List<DateEvent>> getEvents() async => List.unmodifiable(_events);

  @override
  Future<void> saveEvent(DateEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }
}
