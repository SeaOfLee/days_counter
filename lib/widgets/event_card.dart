import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../utils/date_calculations.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final DateEvent event;

  @override
  Widget build(BuildContext context) {
    final days = event.direction == CountDirection.since
        ? daysSince(event.date)
        : daysUntil(event.date);
    final directionLabel = event.direction == CountDirection.since
        ? 'Since ${formatDate(event.date)}'
        : 'Until ${formatDate(event.date)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              formatDayCount(days),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text('days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              directionLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
