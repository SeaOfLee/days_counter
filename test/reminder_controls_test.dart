import 'package:days_counter/app.dart';
import 'package:days_counter/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/notification_bridge_mock.dart';
import 'fakes/widget_bridge_mock.dart';

void main() {
  setUp(() {
    mockWidgetBridgeChannel();
    mockNotificationChannel();
  });

  Future<InMemoryEventRepository> openEditorWithOffset(
    WidgetTester tester, {
    required String days,
    bool ago = false,
  }) async {
    // Tall enough that the reminder chips sit on screen: the default
    // 800x600 surface leaves them past the bottom of the form.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = InMemoryEventRepository(seed: []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [eventRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Vacation');
    await tester.tap(find.text('In days'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Days'), days);
    await tester.pumpAndSettle();
    if (ago) {
      await tester.tap(find.text('Ago'));
      await tester.pumpAndSettle();
    }
    return repository;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byTooltip('Save'));
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('a countdown offers lead times once switched on', (tester) async {
    final repository = await openEditorWithOffset(tester, days: '30');

    expect(find.text('Before the day arrives'), findsOneWidget);
    expect(find.text('1 week before'), findsNothing);

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1 week before'));
    await tester.tap(find.text('1 week before'));
    await tester.pumpAndSettle();
    await save(tester);

    final stored = (await repository.getEvents()).single;
    expect(stored.notify, isTrue);
    expect(stored.notifyDaysBefore, [0, 7]);
    expect(stored.notifyMinuteOfDay, 9 * 60);
  });

  testWidgets('a countdown with every lead time cleared saves as off', (
    tester,
  ) async {
    final repository = await openEditorWithOffset(tester, days: '30');

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('On the day'));
    await tester.tap(find.text('On the day'));
    await tester.pumpAndSettle();
    await save(tester);

    expect((await repository.getEvents()).single.notify, isFalse);
  });

  testWidgets('a count-up offers milestones, with no lead times', (
    tester,
  ) async {
    final repository = await openEditorWithOffset(
      tester,
      days: '10',
      ago: true,
    );

    expect(find.text('At 30, 60, then every 100 days'), findsOneWidget);

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Time'), findsOneWidget);
    expect(find.text('On the day'), findsNothing);

    await save(tester);
    expect((await repository.getEvents()).single.notify, isTrue);
  });
}
