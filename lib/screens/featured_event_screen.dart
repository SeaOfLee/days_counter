import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/date_event.dart';
import '../providers/events_provider.dart';
import '../providers/featured_event_provider.dart';

class FeaturedEventScreen extends ConsumerWidget {
  const FeaturedEventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final featuredIdAsync = ref.watch(featuredEventIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Featured Widget Event')),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('Add an event first.'));
          }
          final featuredId = selectFeaturedEvent(
            events,
            featuredIdAsync.valueOrNull,
          )?.id;
          return RadioGroup<String>(
            groupValue: featuredId,
            onChanged: (id) {
              if (id != null) {
                ref.read(featuredEventIdProvider.notifier).setFeaturedEventId(id);
              }
            },
            child: ListView(
              children: [
                for (final event in events)
                  RadioListTile<String>(value: event.id, title: Text(_eventLabel(event))),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _eventLabel(DateEvent event) {
    return [event.emoji, event.title].whereType<String>().join(' ');
  }
}
