/// Strips the time-of-day component so date math operates on calendar
/// dates rather than 24-hour durations. Normalizes to UTC (not local
/// midnight): a local-midnight-to-local-midnight difference can be 23 or 25
/// hours across a DST transition, which truncates incorrectly under
/// Duration.inDays. UTC days are always exactly 24 hours, so day counts
/// stay correct across DST changes.
DateTime dateOnly(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

int differenceInCalendarDays(DateTime first, DateTime second) {
  return dateOnly(second).difference(dateOnly(first)).inDays;
}

int daysSince(DateTime date, {DateTime? now}) {
  return differenceInCalendarDays(date, now ?? DateTime.now());
}

int daysUntil(DateTime date, {DateTime? now}) {
  return differenceInCalendarDays(now ?? DateTime.now(), date);
}

/// The calendar date [days] away from [now]; negative counts backwards.
///
/// Overflows the day field rather than adding a Duration — Dart normalizes
/// `DateTime(2026, 1, 40)` correctly, whereas `Duration(days: n)` adds fixed
/// 24-hour blocks and so drifts by an hour across a DST boundary, which is
/// exactly what the rest of this file exists to avoid. Returns a local date,
/// matching what the date picker produces.
DateTime dateOffsetBy(int days, {DateTime? now}) {
  final from = now ?? DateTime.now();
  return DateTime(from.year, from.month, from.day + days);
}

/// A day count worth acknowledging with a distinct treatment.
enum Milestone {
  /// Today is the day itself: a countdown reached zero, or the event is
  /// dated today. Rendered as a word rather than a number, since "0 days"
  /// reads like a bug.
  today,

  /// A round-number day count on the way past.
  round,
}

/// Milestones below [_milestoneInterval]. Past that, every multiple of the
/// interval counts, so the gap between acknowledgements never grows.
const _earlyMilestones = {7, 30, 100, 365};

/// Chosen over 1,000 so a long-running count isn't silent for years at a
/// time — this app's headline example is a count in the thousands. It does
/// mean yearly anniversaries past the first (730, 1,095, ...) aren't
/// milestones; only 365 is.
const _milestoneInterval = 500;

/// What kind of moment [days] is, or null for an ordinary day.
///
/// Takes the already-computed count rather than a date, so both count
/// directions land here the same way. Negative counts never match: an
/// `until` event whose date has passed keeps rendering a negative count
/// until it is next saved (see [formatDayCount]), and -100 is not a
/// milestone.
///
/// Mirrored in ios/DaysCounterWidget/WidgetEventStore.swift — the widget
/// renders seven days ahead, so it has to decide this for future dates
/// rather than being told the answer for today.
Milestone? milestoneFor(int days) {
  if (days < 0) return null;
  if (days == 0) return Milestone.today;
  if (_earlyMilestones.contains(days)) return Milestone.round;
  return days % _milestoneInterval == 0 ? Milestone.round : null;
}

String dayCountLabel(int days) {
  final formatted = formatDayCount(days);
  return days == 1 ? '$formatted day' : '$formatted days';
}

/// Adds thousands separators, e.g. 1139 -> "1,139".
String formatDayCount(int days) {
  final digits = days.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return days < 0 ? '-$buffer' : buffer.toString();
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats a date as e.g. "June 19, 2023".
String formatDate(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}
