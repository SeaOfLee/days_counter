import 'package:flutter/material.dart';

import '../models/date_event.dart';
import '../theme/app_colors.dart';
import '../utils/date_calculations.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});

  final DateEvent event;
  final VoidCallback? onTap;

  Color _cardColor(BuildContext context, Milestone? milestone) {
    // A milestone overrides the usual surface in both themes, so the card
    // and the Home Screen widget agree on what today is.
    if (milestone != null) return AppColors.accent;
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.surfaceDark;
    }
    final tints = AppColors.cardTints;
    return tints[event.id.hashCode.abs() % tints.length];
  }

  Color _badgeColor(BuildContext context, Milestone? milestone) {
    if (milestone != null) return Colors.white;
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.moonBadgeDark
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = event.direction == CountDirection.since
        ? daysSince(event.date)
        : daysUntil(event.date);
    final unitLabel = days == 1 ? 'day' : 'days';
    final milestone = milestoneFor(days);
    final foreground = milestone == null ? null : AppColors.onAccent;
    final unitForeground = milestone == null ? null : AppColors.onAccentMuted;

    return Card(
      color: _cardColor(context, milestone),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _badgeColor(context, milestone),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: event.emoji == null
                    ? Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: textTheme.bodyMedium?.color,
                      )
                    : Text(event.emoji!, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: textTheme.titleLarge?.copyWith(color: foreground),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (milestone == Milestone.today)
                          // "0 days" reads like a bug on the one day the
                          // count matters most.
                          Text(
                            'Today',
                            style: textTheme.displayMedium?.copyWith(
                              color: foreground,
                            ),
                          )
                        else ...[
                          Text(
                            formatDayCount(days),
                            style: textTheme.displayMedium?.copyWith(
                              color: foreground,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            unitLabel,
                            style: textTheme.titleMedium?.copyWith(
                              color: unitForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
