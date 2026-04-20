class CalendarEvent {
  final DateTime date;
  final String actionKey; // 'spray', 'check', 'rest', 'harvest', 'recheck'
  final String? note;
  final bool isUrgent;
  final bool isCompleted;

  const CalendarEvent({
    required this.date,
    required this.actionKey,
    this.note,
    this.isUrgent = false,
    this.isCompleted = false,
  });
}
