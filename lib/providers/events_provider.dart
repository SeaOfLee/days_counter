import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../repositories/event_repository.dart';
import '../repositories/local_event_repository.dart';
import '../services/notification_bridge.dart';
import '../services/notification_schedule.dart';
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
    await _sync(events);
    return events;
  }

  Future<void> saveEvent(DateEvent event) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.saveEvent(event);
    final events = await repository.getEvents();
    state = AsyncData(events);
    await _sync(events);
  }

  Future<void> deleteEvent(String id) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.deleteEvent(id);
    final events = await repository.getEvents();
    state = AsyncData(events);
    await _sync(events);
  }

  Future<void> reorderEvents(List<String> orderedIds) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.reorderEvents(orderedIds);
    final events = await repository.getEvents();
    state = AsyncData(events);
    await _sync(events);
  }

  // Awaited deliberately (not fire-and-forget): the app can be backgrounded
  // moments after an edit, and an in-flight platform-channel call can be cut
  // off mid-write if we don't wait for it here.
  //
  // Notifications are rescheduled on the same beat as the widget sync, and
  // for the same reason the schedule is capped: there is no background
  // execution, so whatever is pending when the app closes is all the user
  // gets until they open it again.
  Future<void> _sync(List<DateEvent> events) async {
    await WidgetBridge.updateEvents(events);
    await NotificationBridge.schedule(milestoneNotifications(events));
  }
}
