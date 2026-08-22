import '../models/date_event.dart';
import '../utils/date_calculations.dart';

/// One local notification waiting to be handed to iOS.
///
/// Deliberately dumb: the native side schedules exactly what it is given
/// and decides nothing. Flutter owns the domain, including what counts as a
/// milestone and how it reads.
class PendingNotification {
  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.fireDate,
  });

  /// Stable across reschedules — `<eventId>-<dayCount>` — so rescheduling
  /// replaces a request rather than stacking duplicates on top of it.
  final String id;
  final String title;
  final String body;

  /// Local date and time. Sent as components rather than an instant: the
  /// native side builds a calendar trigger from them, which follows the
  /// user across time zones and doesn't drift over a DST boundary.
  final DateTime fireDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'year': fireDate.year,
      'month': fireDate.month,
      'day': fireDate.day,
      'hour': fireDate.hour,
      'minute': fireDate.minute,
    };
  }
}

/// Notifications fire at 9am local. Midnight is when the count technically
/// changes, but a notification at midnight is one nobody wanted.
const notificationHour = 9;

/// Leaves headroom under the 64 pending local notifications iOS allows an
/// app. Going over doesn't error — iOS silently drops the excess — so the
/// budget is enforced here instead.
const maxPendingNotifications = 60;

/// Every notification worth scheduling right now, soonest first.
///
/// Recomputed from scratch on every call rather than diffed: the native side
/// clears and re-adds, and a few dozen requests is nothing. Events that
/// haven't opted in are skipped entirely.
List<PendingNotification> milestoneNotifications(
  List<DateEvent> events, {
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  final pending = <PendingNotification>[];

  for (final event in events) {
    if (!event.notify) continue;

    final countingDown = event.direction == CountDirection.until;
    final currentDays = countingDown
        ? daysUntil(event.date, now: currentTime)
        : daysSince(event.date, now: currentTime);

    for (final days in upcomingMilestoneCounts(
      currentDays,
      countingDown: countingDown,
    )) {
      final date = dateOfMilestone(event.date, days, countingDown: countingDown);
      final fireDate = DateTime(date.year, date.month, date.day, notificationHour);

      // A milestone earlier today has already gone by; iOS would fire a
      // calendar trigger in the past immediately, which reads as a bug.
      if (!fireDate.isAfter(currentTime)) continue;

      pending.add(
        PendingNotification(
          id: '${event.id}-$days',
          title: _title(event),
          body: _body(days, countingDown: countingDown),
          fireDate: fireDate,
        ),
      );
    }
  }

  pending.sort((a, b) => a.fireDate.compareTo(b.fireDate));
  return pending.take(maxPendingNotifications).toList();
}

/// Matches how the event cards read, e.g. "🍺 Last Drink".
String _title(DateEvent event) {
  return [event.emoji, event.title].whereType<String>().join(' ');
}

String _body(int days, {required bool countingDown}) {
  if (days == 0) return "Today's the day.";
  return countingDown
      ? '${dayCountLabel(days)} to go.'
      : '${dayCountLabel(days)} today.';
}
