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
}
