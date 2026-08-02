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
