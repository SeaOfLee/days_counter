import '../models/date_event.dart';
import '../utils/date_calculations.dart';

/// One local notification waiting to be handed to iOS.
///
/// Deliberately dumb: the native side schedules exactly what it is given
/// and decides nothing. Flutter owns the domain, including which days are
/// worth a notification and how they read.
class PendingNotification {
  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.fireDate,
  });

  /// `<eventId>-<dayCount>`, stable across reschedules so rescheduling
  /// replaces a request rather than stacking duplicates on top of it. The
  /// day count is in the identifier rather than a bare "0" so a second rule
  /// can add `-100` or `-365` later without colliding.
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

/// Leaves headroom under the 64 pending local notifications iOS allows an
/// app. Going over doesn't error — iOS silently drops the excess — so the
/// budget is enforced here instead.
const maxPendingNotifications = 60;

/// Every notification worth scheduling right now, soonest first.
///
/// Recomputed from scratch on every call rather than diffed: the native
/// side clears and re-adds, and a few dozen requests is nothing. Events
/// that haven't opted in are skipped entirely.
List<PendingNotification> plannedNotifications(
  List<DateEvent> events, {
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  final pending = <PendingNotification>[];

  for (final event in events) {
    if (!event.notify) continue;
    pending.addAll(_notificationsFor(event, currentTime));
  }

  pending.sort((a, b) => a.fireDate.compareTo(b.fireDate));
  return pending.take(maxPendingNotifications).toList();
}

/// The reminder offsets a countdown can choose from, in days before its
/// date. A fixed set rather than free entry: it keeps the editor to one row
/// of chips and keeps the per-event count bounded under the budget above.
const reminderLeadDays = [0, 1, 7];

/// Day counts a count-up announces: 30, 60, then every hundred. Separate
/// from [milestoneFor], which drives the visual treatment and has its own
/// set — a notification interrupts, so it gets a sparser rule than a card
/// that is only restyled. Tune here; nothing else knows the numbers.
bool isNotificationMilestone(int days) {
  if (days <= 0) return false;
  if (days == 30 || days == 60) return true;
  return days % 100 == 0;
}

/// How many upcoming milestones to queue per count-up. Scheduling only
/// happens while the app is open, so this is how far ahead a user who stops
/// opening it stays covered — past day 100 that is years.
const milestonesPerEvent = 3;

/// The rules for one event: a countdown's chosen reminders ahead of its
/// date, or a count-up's next few milestones.
Iterable<PendingNotification> _notificationsFor(
  DateEvent event,
  DateTime now,
) sync* {
  final title = notificationTitleFor(event);

  if (event.direction == CountDirection.until) {
    for (final daysBefore in event.notifyDaysBefore.toSet()) {
      final fireDate = _fireDate(event, dayOffset: -daysBefore);
      // The time may already have gone by; iOS fires a calendar trigger set
      // in the past immediately, which reads as a bug.
      if (!fireDate.isAfter(now)) continue;
      yield PendingNotification(
        id: '${event.id}-$daysBefore',
        title: title,
        body: countdownBody(daysBefore),
        fireDate: fireDate,
      );
    }
    return;
  }

  var found = 0;
  // Starts at today's count, not the next one: today's milestone is still
  // worth announcing if its time hasn't passed yet.
  for (
    var days = daysSince(event.date, now: now);
    found < milestonesPerEvent;
    days++
  ) {
    if (!isNotificationMilestone(days)) continue;
    final fireDate = _fireDate(event, dayOffset: days);
    if (!fireDate.isAfter(now)) continue;
    found++;
    yield PendingNotification(
      id: '${event.id}-$days',
      title: title,
      body: '${dayCountLabel(days)} today.',
      fireDate: fireDate,
    );
  }
}

/// The local date and time [dayOffset] days from the event's date, at its
/// chosen time. Overflows the day field rather than adding a Duration, for
/// the same DST reason as [dateOffsetBy].
DateTime _fireDate(DateEvent event, {required int dayOffset}) {
  final day = dateOffsetBy(dayOffset, now: event.date);
  return DateTime(day.year, day.month, day.day, 0, event.notifyMinuteOfDay);
}

/// Names the event. This was generic in Phase 26 to keep event names off
/// the lock screen; that was reversed by the user's call in Phase 27 —
/// knowing which date arrived is worth more than hiding it. iOS's own
/// "Show Previews: When Unlocked" setting remains the way to hide it.
String notificationTitleFor(DateEvent event) {
  final emoji = event.emoji;
  return emoji == null ? event.title : '$emoji ${event.title}';
}

String countdownBody(int daysBefore) {
  if (daysBefore == 0) return "Today's the day.";
  if (daysBefore == 1) return 'Tomorrow.';
  return '${dayCountLabel(daysBefore)} to go.';
}
