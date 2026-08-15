import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/date_event.dart';
import 'event_repository.dart';

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

  // Phase 18's featured_event_id.txt is no longer read or written — each
  // widget instance now picks its own event. Existing installs keep the
  // orphaned file; deleting it would mean inventing a one-shot migration
  // to reclaim a few dozen bytes.

  Future<List<DateEvent>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final file = await _eventsFile();
    if (!await file.exists()) {
      // First run: start empty so the user builds their own list. Must be a
      // growable list — saveEvent mutates the cache in place.
      final empty = <DateEvent>[];
      _cache = empty;
      return empty;
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

  @override
  Future<void> reorderEvents(List<String> orderedIds) async {
    final events = await _load();
    final byId = {for (final event in events) event.id: event};

    final reordered = [
      for (final id in orderedIds) ?byId.remove(id),
    ];
    // Anything the caller didn't name keeps its relative position at the
    // end, so a stale id list can reorder but never silently drop events.
    reordered.addAll(events.where((event) => byId.containsKey(event.id)));

    // Mutated in place: _cache holds this same list instance.
    events
      ..clear()
      ..addAll(reordered);
    await _persist(events);
  }

}
