import '../models/date_event.dart';

abstract class EventRepository {
  Future<List<DateEvent>> getEvents();

  Future<void> saveEvent(DateEvent event);

  Future<void> deleteEvent(String id);

  Future<String?> getFeaturedEventId();

  Future<void> setFeaturedEventId(String? id);
}
