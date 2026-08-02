import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/date_event.dart';
import 'event_repository.dart';

List<DateEvent> _seedEvents() => [
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

/// Persists events as a JSON file in the app's documents directory. The
/// [directoryProvider] seam lets tests point this at a temp directory
/// instead of going through the path_provider platform channel.
class LocalEventRepository implements EventRepository {
  LocalEventRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;
  List<DateEvent>? _cache;

  Future<File> _eventsFile() async {
    final dir = await _directoryProvider();
    return File('${dir.path}/events.json');
  }

  Future<List<DateEvent>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final file = await _eventsFile();
    if (!await file.exists()) {
      final seeded = _seedEvents();
      _cache = seeded;
      await _persist(seeded);
      return seeded;
    }

    final contents = await file.readAsString();
    final decoded = jsonDecode(contents) as List<dynamic>;
    final events = decoded
        .map((json) => DateEvent.fromJson(json as Map<String, dynamic>))
        .toList();
    _cache = events;
    return events;
  }

  Future<void> _persist(List<DateEvent> events) async {
    final file = await _eventsFile();
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await file.writeAsString(encoded);
  }

  @override
  Future<List<DateEvent>> getEvents() async {
    return List.unmodifiable(await _load());
  }

  @override
  Future<void> saveEvent(DateEvent event) async {
    final events = await _load();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await _persist(events);
  }

  @override
  Future<void> deleteEvent(String id) async {
    final events = await _load();
    events.removeWhere((e) => e.id == id);
    await _persist(events);
  }
}
