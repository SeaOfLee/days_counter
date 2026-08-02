import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/screens/event_list_screen.dart';

void main() {
  testWidgets('tapping + opens the editor, saving adds the event to the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: EventListScreen()),
    );

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
    await tester.pumpWidget(
      const MaterialApp(home: EventListScreen()),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Event'), findsOneWidget);
    expect(find.text('Enter a name for this event'), findsOneWidget);
    expect(find.text('Choose a date'), findsOneWidget);
  });
}
