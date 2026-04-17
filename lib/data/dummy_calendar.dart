import '../models/calendar_event.dart';

class DummyCalendar {
  DummyCalendar._();

  static List<CalendarEvent> get schedule {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      CalendarEvent(
        date: today,
        actionKey: 'spray',
        note: 'Mancozeb evening spray',
        isUrgent: true,
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 1)),
        actionKey: 'rest',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 2)),
        actionKey: 'rest',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 3)),
        actionKey: 'recheck',
        note: 'Check treated leaves',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 4)),
        actionKey: 'rest',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 5)),
        actionKey: 'spray',
        note: 'Follow-up Mancozeb spray',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 6)),
        actionKey: 'rest',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 10)),
        actionKey: 'recheck',
        note: 'Final disease check',
      ),
      CalendarEvent(
        date: today.add(const Duration(days: 21)),
        actionKey: 'harvest',
        note: 'Safe harvest window opens',
      ),
    ];
  }
}
