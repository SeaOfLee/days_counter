import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../repositories/event_repository.dart';
import '../repositories/local_event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return LocalEventRepository();
});

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<DateEvent>>(
  EventsNotifier.new,
);

class EventsNotifier extends AsyncNotifier<List<DateEvent>> {
  @override
  Future<List<DateEvent>> build() {
    return ref.read(eventRepositoryProvider).getEvents();
  }

  Future<void> saveEvent(DateEvent event) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.saveEvent(event);
    state = AsyncData(await repository.getEvents());
  }

  Future<void> deleteEvent(String id) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.deleteEvent(id);
    state = AsyncData(await repository.getEvents());
  }
}
