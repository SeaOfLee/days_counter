import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/theme/app_colors.dart';
import 'package:days_counter/theme/app_theme.dart';
import 'package:days_counter/utils/date_calculations.dart';
import 'package:days_counter/widgets/event_card.dart';

/// An event whose day count lands exactly [days] away from today, so the
/// card computes the milestone itself rather than being told.
DateEvent eventCounting(int days, {String title = 'Last Drink'}) {
  return DateEvent(
    id: 'test-$days',
    title: title,
    date: dateOffsetBy(-days),
    direction: CountDirection.since,
  );
}

Future<void> pumpCard(WidgetTester tester, DateEvent event) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: EventCard(event: event)),
    ),
  );
}

Card cardOf(WidgetTester tester) =>
    tester.widget<Card>(find.byType(Card).first);

Color colorOfText(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  group('event card on an ordinary day', () {
    testWidgets('shows the count and the unit label', (tester) async {
      await pumpCard(tester, eventCounting(247));

      expect(find.text('247'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('keeps its usual card tint', (tester) async {
      await pumpCard(tester, eventCounting(247));

      expect(cardOf(tester).color, isNot(AppColors.accent));
    });
  });

  group('event card on a round milestone', () {
    testWidgets('still shows the number, not a word', (tester) async {
      await pumpCard(tester, eventCounting(1000));

      expect(find.text('1,000'), findsOneWidget);
      expect(find.text('days'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('takes the accent surface', (tester) async {
      await pumpCard(tester, eventCounting(1000));

      expect(cardOf(tester).color, AppColors.accent);
    });

    testWidgets('uses inks that stay readable on the accent', (tester) async {
      await pumpCard(tester, eventCounting(1000));

      expect(colorOfText(tester, '1,000'), AppColors.onAccent);
      expect(colorOfText(tester, 'Last Drink'), AppColors.onAccent);
      expect(colorOfText(tester, 'days'), AppColors.onAccentMuted);
    });
  });

  group('event card on the day itself', () {
    testWidgets('reads "Today" rather than a bare zero', (tester) async {
      await pumpCard(tester, eventCounting(0));

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      // The unit label would be meaningless next to a word.
      expect(find.text('days'), findsNothing);
    });

    testWidgets('takes the accent surface too', (tester) async {
      await pumpCard(tester, eventCounting(0));

      expect(cardOf(tester).color, AppColors.accent);
      expect(colorOfText(tester, 'Today'), AppColors.onAccent);
    });
  });

  group('event card the day either side of a milestone', () {
    testWidgets('reverts to the ordinary treatment', (tester) async {
      await pumpCard(tester, eventCounting(1001));

      expect(find.text('1,001'), findsOneWidget);
      expect(cardOf(tester).color, isNot(AppColors.accent));
    });

    testWidgets('is ordinary the day before, too', (tester) async {
      await pumpCard(tester, eventCounting(999));

      expect(find.text('999'), findsOneWidget);
      expect(cardOf(tester).color, isNot(AppColors.accent));
    });
  });
}
