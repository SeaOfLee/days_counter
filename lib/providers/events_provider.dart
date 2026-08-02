import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../repositories/event_repository.dart';
import '../repositories/local_event_repository.dart';
import '../services/widget_bridge.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return LocalEventRepository();
});

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<DateEvent>>(
  EventsNotifier.new,
);

class EventsNotifier extends AsyncNotifier<List<DateEvent>> {
  @override
  Future<List<DateEvent>> build() async {
    final events = await ref.read(eventRepositoryProvider).getEvents();
    await _syncFeaturedEventToWidget(events);
    return events;
  }

  Future<void> saveEvent(DateEvent event) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.saveEvent(event);
    final events = await repository.getEvents();
    state = AsyncData(events);
    await _syncFeaturedEventToWidget(events);
  }

  Future<void> deleteEvent(String id) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.deleteEvent(id);
    final events = await repository.getEvents();
    state = AsyncData(events);
    await _syncFeaturedEventToWidget(events);
  }

  // There's no featured-event setting yet (Phase 18), so the first event
  // stands in as a temporary placeholder for "the event shown in the widget".
  // Awaited deliberately (not fire-and-forget): the app can be backgrounded
  // moments after an edit, and an in-flight platform-channel call can be cut
  // off mid-write if we don't wait for it here.
  Future<void> _syncFeaturedEventToWidget(List<DateEvent> events) {
    return WidgetBridge.updateFeaturedEvent(
      events.isEmpty ? null : events.first,
    );
  }
}
