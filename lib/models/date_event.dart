enum CountDirection {
  since,
  until,
}

class DateEvent {
  final String id;
  final String title;
  final DateTime date;
  final CountDirection direction;
  final String? emoji;

  DateEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.direction,
    this.emoji,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': '${date.year}-${_pad(date.month)}-${_pad(date.day)}',
      'direction': direction.name,
      'emoji': emoji,
    };
  }

  factory DateEvent.fromJson(Map<String, dynamic> json) {
    return DateEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      direction: CountDirection.values.byName(json['direction'] as String),
      emoji: json['emoji'] as String?,
    );
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
