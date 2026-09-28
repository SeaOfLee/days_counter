enum CountDirection { since, until }

class DateEvent {
  final String id;
  final String title;
  final DateTime date;
  final CountDirection direction;
  final String? emoji;

  /// Whether this event asks for local notifications at all. Opt-in per
  /// event: most events don't warrant one. What it announces depends on
  /// direction — a countdown's arrival, or a count-up's milestones.
  final bool notify;

  /// Time of day notifications fire, as minutes after local midnight.
  final int notifyMinuteOfDay;

  /// For a countdown, how many days ahead of the date to remind: 0 is the
  /// day itself. Ignored for a count-up, whose days are its milestones.
  final List<int> notifyDaysBefore;

  DateEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.direction,
    this.emoji,
    this.notify = false,
    this.notifyMinuteOfDay = defaultNotifyMinuteOfDay,
    this.notifyDaysBefore = const [0],
  });

  /// 9am. Midnight is when the count technically changes, but a
  /// notification at midnight is one nobody wanted.
  static const defaultNotifyMinuteOfDay = 9 * 60;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': '${date.year}-${_pad(date.month)}-${_pad(date.day)}',
      'direction': direction.name,
      'emoji': emoji,
      'notify': notify,
      'notifyMinuteOfDay': notifyMinuteOfDay,
      'notifyDaysBefore': notifyDaysBefore,
    };
  }

  factory DateEvent.fromJson(Map<String, dynamic> json) {
    return DateEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      direction: CountDirection.values.byName(json['direction'] as String),
      emoji: json['emoji'] as String?,
      // Absent in files written before Phase 26; those events simply
      // haven't opted in.
      notify: json['notify'] as bool? ?? false,
      // Both absent in files written before Phase 27; the defaults are
      // exactly what those events were already getting.
      notifyMinuteOfDay:
          json['notifyMinuteOfDay'] as int? ?? defaultNotifyMinuteOfDay,
      notifyDaysBefore:
          (json['notifyDaysBefore'] as List<dynamic>?)?.cast<int>() ??
          const [0],
    );
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
