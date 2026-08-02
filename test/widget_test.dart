import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/app.dart';
import 'package:days_counter/providers/events_provider.dart';

import 'fakes/in_memory_event_repository.dart';

void main() {
  testWidgets('shows every in-memory event', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(InMemoryEventRepository()),
        ],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.text('Days'), findsOneWidget);
    expect(find.textContaining('Last Drink'), findsOneWidget);
    expect(find.textContaining('Started New Job'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('Anniversary'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.textContaining('Vacation'), findsOneWidget);
    expect(find.textContaining('Anniversary'), findsOneWidget);
  });
}
