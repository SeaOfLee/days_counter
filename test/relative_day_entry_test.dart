import 'package:days_counter/app.dart';
import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/providers/events_provider.dart';
import 'package:days_counter/utils/date_calculations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/widget_bridge_mock.dart';

void main() {
  setUp(mockWidgetBridgeChannel);

  Future<InMemoryEventRepository> pumpApp(WidgetTester tester) async {
    final repository = InMemoryEventRepository(seed: []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [eventRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  Future<void> openEditorAndName(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, name);
    await tester.pumpAndSettle();
  }

  testWidgets('entering days from now creates a future event', (tester) async {
    final repository = await pumpApp(tester);
    await openEditorAndName(tester, 'Marathon');

    await tester.tap(find.text('In days'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Days'), '100');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    final stored = await repository.getEvents();
    expect(stored, hasLength(1));
    expect(stored.single.title, 'Marathon');
    expect(stored.single.date, dateOffsetBy(100));
    // A future date counts down, with no toggle asked for.
    expect(stored.single.direction, CountDirection.until);
  });

  testWidgets('"Ago" counts backwards and infers since', (tester) async {
    final repository = await pumpApp(tester);
    await openEditorAndName(tester, 'Quit Coffee');

    await tester.tap(find.text('In days'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Days'), '30');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ago'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    final stored = await repository.getEvents();
    expect(stored.single.date, dateOffsetBy(-30));
    expect(stored.single.direction, CountDirection.since);
  });

  testWidgets('the computed date is previewed before saving', (tester) async {
    await pumpApp(tester);
    await openEditorAndName(tester, 'Marathon');

    await tester.tap(find.text('In days'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Days'), '100');
    await tester.pumpAndSettle();

    expect(find.text(formatDate(dateOffsetBy(100))), findsOneWidget);
  });

  testWidgets('a non-numeric offset is rejected', (tester) async {
    final repository = await pumpApp(tester);
    await openEditorAndName(tester, 'Marathon');

    await tester.tap(find.text('In days'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Days'), 'soon');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a number of days'), findsOneWidget);
    expect(await repository.getEvents(), isEmpty);
  });

  testWidgets('the Since/Until toggle is gone', (tester) async {
    await pumpApp(tester);
    await openEditorAndName(tester, 'Marathon');

    expect(find.text('Since'), findsNothing);
    expect(find.text('Until'), findsNothing);
  });
}
