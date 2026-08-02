import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../repositories/event_repository.dart';
import '../widgets/event_card.dart';
import 'event_edit_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key, required this.repository});

  final EventRepository repository;

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<DateEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await widget.repository.getEvents();
    setState(() => _events = events);
  }

  Future<void> _addEvent() async {
    final newEvent = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => const EventEditScreen()),
    );
    if (newEvent is DateEvent) {
      await widget.repository.saveEvent(newEvent);
      await _loadEvents();
    }
  }

  Future<void> _editEvent(DateEvent event) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => EventEditScreen(event: event)),
    );
    if (result is DateEvent) {
      await widget.repository.saveEvent(result);
      await _loadEvents();
    } else if (result is DeleteEvent) {
      await widget.repository.deleteEvent(event.id);
      await _loadEvents();
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
