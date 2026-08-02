import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/screens/event_list_screen.dart';

import 'fakes/in_memory_event_repository.dart';

Future<void> _pumpEventList(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: EventListScreen(repository: InMemoryEventRepository())),
  );
  await tester.pump();
}

void main() {
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

    await tester.tap(find.text('Last Drink'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Event Name'), findsOneWidget);
    expect(find.text('Last Drink'), findsOneWidget);
    expect(find.text('June 19, 2023'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Event Name'),
      'Sobriety Anniversary',
    );
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsNothing);
    expect(find.text('Sobriety Anniversary'), findsOneWidget);
    expect(find.text('Last Drink'), findsNothing);
  });

  testWidgets('deleting an event removes it from the list', (
    WidgetTester tester,
  ) async {
    await _pumpEventList(tester);

    await tester.tap(find.text('Last Drink'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Event'), findsNothing);
    expect(find.text('Last Drink'), findsNothing);
  });
}
