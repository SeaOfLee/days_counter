import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../services/widget_bridge.dart';
import 'events_provider.dart';

final featuredEventIdProvider =
    AsyncNotifierProvider<FeaturedEventIdNotifier, String?>(
      FeaturedEventIdNotifier.new,
    );

class FeaturedEventIdNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.read(eventRepositoryProvider).getFeaturedEventId();
  }

  Future<void> setFeaturedEventId(String id) async {
    await ref.read(eventRepositoryProvider).setFeaturedEventId(id);
    state = AsyncData(id);
    final events = await ref.read(eventsProvider.future);
    await WidgetBridge.updateFeaturedEvent(selectFeaturedEvent(events, id));
  }
}

/// Picks the event the widget should display: the explicitly featured one,
/// or the first event as a fallback if nothing's been chosen yet (or the
/// chosen one was deleted).
DateEvent? selectFeaturedEvent(List<DateEvent> events, String? featuredEventId) {
  if (events.isEmpty) return null;
  return events.firstWhere(
    (event) => event.id == featuredEventId,
    orElse: () => events.first,
  );
}
