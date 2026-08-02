import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../widgets/event_card.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = DateEvent(
      id: '1',
      title: 'Last Drink',
      date: DateTime(2023, 6, 19),
      direction: CountDirection.since,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Days')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: EventCard(event: event),
        ),
      ),
    );
  }
}
