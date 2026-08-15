import '../models/date_event.dart';

abstract class EventRepository {
  Future<List<DateEvent>> getEvents();

  Future<void> saveEvent(DateEvent event);

  Future<void> deleteEvent(String id);

  /// Stores [orderedIds] as the new event order. Order is just position in
  /// the persisted array — there's no sortOrder field — but [getEvents]
  /// returns an unmodifiable list and [saveEvent] only appends or replaces
  /// in place, so rearranging needs its own method.
  Future<void> reorderEvents(List<String> orderedIds);
}
