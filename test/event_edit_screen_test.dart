import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/providers/events_provider.dart';
import 'package:days_counter/screens/event_list_screen.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/notification_bridge_mock.dart';
import 'fakes/widget_bridge_mock.dart';

Future<void> _pumpEventList(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(InMemoryEventRepository()),
      ],
      child: const MaterialApp(home: EventListScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    mockWidgetBridgeChannel();
    mockNotificationChannel();
  });

  testWidgets('tapping + opens the editor, saving adds the event to the list', (
    WidgetTester tester,
  ) async {
    await _pumpEventList(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('New Event'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Event Name'),
      'Marathon',
    );

    await tester.tap(find.text('Select a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Event'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Marathon'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Marathon'), findsOneWidget);
  });

  testWidgets('blank name is rejected by form validation', (
    WidgetTester tester,
  ) async {
    await _pumpEventList(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Event'), findsOneWidget);
    expect(find.text('Enter a name for this event'), findsOneWidget);
    expect(find.text('Choose a date'), findsOneWidget);
  });

  testWidgets('tapping an event opens the editor prepopulated for editing', (
    WidgetTester tester,
  ) async {
    await _pumpEventList(tester);

    await tester.tap(find.textContaining('Last Drink'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Event Name'), findsOneWidget);
    // EventCard now renders the title as a bare Text (no emoji
    // concatenation), so the still-mounted list card behind this route
    // also matches 'Last Drink' — scope to the edit form's field.
    expect(
      find.descendant(
        of: find.byType(TextFormField),
        matching: find.text('Last Drink'),
      ),
      findsOneWidget,
    );
    expect(find.text('June 19, 2023'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Event Name'),
      'Sobriety Anniversary',
    );
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsNothing);
    expect(find.textContaining('Sobriety Anniversary'), findsOneWidget);
    expect(find.textContaining('Last Drink'), findsNothing);
  });

  testWidgets('deleting an event removes it from the list', (
    WidgetTester tester,
  ) async {
    await _pumpEventList(tester);

    await tester.tap(find.textContaining('Last Drink'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsNothing);
    expect(find.textContaining('Last Drink'), findsNothing);
  });
}
