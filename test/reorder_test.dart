import 'package:days_counter/app.dart';
import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/providers/events_provider.dart';
import 'package:days_counter/widgets/event_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/widget_bridge_mock.dart';

void main() {
  setUp(mockWidgetBridgeChannel);

  List<String> renderedTitles(WidgetTester tester) => tester
      .widgetList<EventCard>(find.byType(EventCard))
      .map((card) => card.event.title)
      .toList();

  testWidgets('dragging a card down reorders the list', (tester) async {
    final repository = InMemoryEventRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [eventRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    final before = renderedTitles(tester);
    expect(before.first, 'Last Drink');

    // Long press to pick the card up, then drag it past the next one.
    final firstCard = find.text('Last Drink');
    final gesture = await tester.startGesture(tester.getCenter(firstCard));
    await tester.pump(kLongPressTimeout + kPressTimeout);
    await gesture.moveBy(const Offset(0, 160));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    final after = renderedTitles(tester);
    expect(after, isNot(before));
    expect(after.first, isNot('Last Drink'));
    expect(after.contains('Last Drink'), isTrue);
    expect(after.length, before.length);
  });

  testWidgets('the new order reaches the repository', (tester) async {
    final repository = InMemoryEventRepository(
      seed: [
        DateEvent(
          id: '1',
          title: 'First',
          date: DateTime(2024, 1, 1),
          direction: CountDirection.since,
        ),
        DateEvent(
          id: '2',
          title: 'Second',
          date: DateTime(2024, 1, 2),
          direction: CountDirection.since,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [eventRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('First')),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    // Move in steps: the list decides a swap from intermediate drag
    // positions, not just where the finger lands.
    for (var i = 0; i < 8; i++) {
      await gesture.moveBy(const Offset(0, 25));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final stored = await repository.getEvents();
    expect(stored.map((e) => e.id).toList(), ['2', '1']);
  });
}
