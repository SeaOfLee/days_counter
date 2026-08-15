import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/widget_bridge_mock.dart';

/// The App Group payload is this phase's whole contract with the widget, and
/// it's the only place the app's event order reaches WidgetKit — so it needs
/// its own coverage rather than riding along on a UI test.
void main() {
  late RecordingWidgetBridge bridge;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    bridge = RecordingWidgetBridge()..install();
  });

  ProviderContainer containerWith(InMemoryEventRepository repository) {
    final container = ProviderContainer(
      overrides: [eventRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('sends every event, in list order, on first load', () async {
    final container = containerWith(InMemoryEventRepository());

    await container.read(eventsProvider.future);

    expect(bridge.lastCall.method, 'updateEvents');
    expect(bridge.lastEventIds, ['1', '2', '3', '4']);
  });

  test('a saved event is appended to the payload', () async {
    final container = containerWith(InMemoryEventRepository());
    await container.read(eventsProvider.future);

    await container.read(eventsProvider.notifier).saveEvent(
      DateEvent(
        id: '5',
        title: 'Marathon',
        date: DateTime(2026, 10, 4),
        direction: CountDirection.until,
      ),
    );

    expect(bridge.lastEventIds, ['1', '2', '3', '4', '5']);
  });

  test('a deleted event drops out of the payload', () async {
    final container = containerWith(InMemoryEventRepository());
    await container.read(eventsProvider.future);

    await container.read(eventsProvider.notifier).deleteEvent('2');

    expect(bridge.lastEventIds, ['1', '3', '4']);
  });

  test('an empty list is sent as "[]", never null', () async {
    // The widget tells "the user has no events" from "nothing has ever been
    // synced" by whether the key exists, so this must not send null.
    final container = containerWith(InMemoryEventRepository(seed: []));

    await container.read(eventsProvider.future);

    expect(bridge.lastCall.arguments, '[]');
  });

  test('payload carries the fields the widget decodes', () async {
    final container = containerWith(InMemoryEventRepository());

    await container.read(eventsProvider.future);

    expect(bridge.lastEvents.first, {
      'id': '1',
      'title': 'Last Drink',
      'date': '2023-06-19',
      'direction': 'since',
      'emoji': '🍺',
    });
  });
}
