import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'event_edit_screen.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  Future<void> _addEvent(BuildContext context, WidgetRef ref) async {
    final newEvent = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => const EventEditScreen()),
    );
    if (newEvent is DateEvent) {
      await ref.read(eventsProvider.notifier).saveEvent(newEvent);
    }
  }

  Future<void> _editEvent(
    BuildContext context,
    WidgetRef ref,
    DateEvent event,
  ) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (context) => EventEditScreen(event: event)),
    );
    if (result is DateEvent) {
      await ref.read(eventsProvider.notifier).saveEvent(result);
    } else if (result is DeleteEvent) {
      await ref.read(eventsProvider.notifier).deleteEvent(event.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Days')),
      body: eventsAsync.when(
        data: (events) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(
                event: event,
                onTap: () => _editEvent(context, ref, event),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEvent(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
