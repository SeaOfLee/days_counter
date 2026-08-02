import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../widgets/event_card.dart';
import 'event_edit_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final List<DateEvent> _events = [
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

  Future<void> _addEvent() async {
    final newEvent = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => const EventEditScreen()),
    );
    if (newEvent is DateEvent) {
      setState(() => _events.add(newEvent));
    }
  }

  Future<void> _editEvent(DateEvent event) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => EventEditScreen(event: event)),
    );
    if (result is DateEvent) {
      setState(() {
        _events[_events.indexWhere((e) => e.id == event.id)] = result;
      });
    } else if (result is DeleteEvent) {
      setState(() => _events.removeWhere((e) => e.id == event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Days')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(event: event, onTap: () => _editEvent(event)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
