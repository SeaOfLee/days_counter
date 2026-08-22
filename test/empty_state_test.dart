import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/providers/events_provider.dart';
import 'package:days_counter/screens/event_list_screen.dart';

import 'fakes/in_memory_event_repository.dart';
import 'fakes/notification_bridge_mock.dart';
import 'fakes/widget_bridge_mock.dart';

void main() {
  setUp(() {
    mockWidgetBridgeChannel();
    mockNotificationChannel();
  });

  testWidgets('shows an empty state when there are no events', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            InMemoryEventRepository(seed: []),
          ),
        ],
        child: const MaterialApp(home: EventListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No events yet'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });
}
