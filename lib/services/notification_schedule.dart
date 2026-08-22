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

/// Notifications fire at 9am local. Midnight is when the count technically
/// changes, but a notification at midnight is one nobody wanted.
const notificationHour = 9;

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

/// The rules for one event.
///
/// There is exactly one today: a countdown tells you on the day it arrives.
/// It is written as a function yielding a list rather than returning a
/// single value so that adding a rule — round-number milestones, a
/// day-before heads-up — is an addition here rather than a restructure of
/// everything above.
Iterable<PendingNotification> _notificationsFor(
  DateEvent event,
  DateTime now,
) sync* {
  // Only a countdown has a day to look forward to. An event counting up
  // from the past has no future arrival, which is why the editor doesn't
  // offer the toggle for one.
  if (event.direction != CountDirection.until) return;

  final fireDate = DateTime(
    event.date.year,
    event.date.month,
    event.date.day,
    notificationHour,
  );

  // 9am on the day may already have gone by; iOS fires a calendar trigger
  // set in the past immediately, which reads as a bug.
  if (!fireDate.isAfter(now)) return;

  yield PendingNotification(
    id: '${event.id}-0',
    title: notificationTitle,
    body: notificationBody,
    fireDate: fireDate,
  );
}

/// Deliberately says nothing about which event arrived.
///
/// Notification text renders on the lock screen, in front of whoever else
/// is in the room, and the names people give these events are often the
/// private part — this app's own headline example is "Last Drink". Naming
/// the event would be more useful and is the obvious thing to want; it is
/// traded away on purpose. Opening the app shows which date it was.
const notificationTitle = 'Dayward';
const notificationBody = "Today's the day.";

/// Whether [date] can carry a reminder at all — that is, whether its
/// arrival is still ahead. Shared with the editor so the toggle and the
/// scheduler agree on what is eligible.
bool canNotifyFor(DateTime date, {DateTime? now}) {
  return daysUntil(date, now: now) > 0;
}
