import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../providers/events_provider.dart';
import '../theme/app_colors.dart';
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
      // No widget-picker action here any more: each Home Screen widget
      // chooses its own event via long press -> Edit Widget.
      appBar: AppBar(title: const Text('Dayward')),
      body: eventsAsync.when(
        data: (events) => events.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.cardLavender,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.calendar_today_outlined,
                size: 28,
                color: AppColors.accent,
              ),
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
