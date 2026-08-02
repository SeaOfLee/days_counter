import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/app.dart';

void main() {
  testWidgets('shows the hard-coded event with its day count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    expect(find.text('Days'), findsOneWidget);
    expect(find.text('Last Drink'), findsOneWidget);
    expect(find.text('days'), findsOneWidget);
  });
}
