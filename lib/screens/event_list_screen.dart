import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../widgets/event_card.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  static final List<DateEvent> _events = [
    DateEvent(
      id: '1',
      title: 'Last Drink',
      date: DateTime(2023, 6, 19),
      direction: CountDirection.since,
      emoji: '🍺',
    ),
    DateEvent(
      id: '2',
      title: 'Started New Job',
      date: DateTime(2025, 12, 6),
      direction: CountDirection.since,
      emoji: '💼',
    ),
    DateEvent(
      id: '3',
      title: 'Vacation',
      date: DateTime(2026, 8, 19),
      direction: CountDirection.until,
      emoji: '✈️',
    ),
    DateEvent(
      id: '4',
      title: 'Anniversary',
      date: DateTime(2026, 9, 12),
      direction: CountDirection.until,
      emoji: '💍',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Days')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(event: _events[index]),
          );
        },
      ),
    );
  }
}
