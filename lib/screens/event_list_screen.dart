import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'event_edit_screen.dart';
import 'featured_event_screen.dart';

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
      appBar: AppBar(
        title: const Text('Days'),
        actions: [
          IconButton(
            icon: const Icon(Icons.widgets_outlined),
            tooltip: 'Featured Widget Event',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeaturedEventScreen()),
            ),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? const _EmptyState()
            : ListView.builder(
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No events yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to track the days since or until a date that matters to you.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
