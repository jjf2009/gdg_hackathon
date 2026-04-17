import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/calendar_event.dart';

class SprayCalendar extends StatelessWidget {
  final List<CalendarEvent> events;
  const SprayCalendar({super.key, required this.events});

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  IconData _iconFor(String action) {
    switch (action) {
      case 'spray': return Icons.water_drop_rounded;
      case 'check': case 'recheck': return Icons.search_rounded;
      case 'harvest': return Icons.agriculture_rounded;
      default: return Icons.remove_rounded;
    }
  }

  Color _colorFor(String action) {
    switch (action) {
      case 'spray': return CropDocColors.primary;
      case 'check': case 'recheck': return CropDocColors.warning;
      case 'harvest': return CropDocColors.safe;
      default: return CropDocColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Show next 7 days
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 18, color: CropDocColors.primary),
              const SizedBox(width: 8),
              Text(t(context, 'spray_schedule'),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          // 7-day strip
          SizedBox(
            height: 88,
            child: Row(
              children: days.map((day) {
                final isToday = day == today;
                CalendarEvent? event;
                for (final e in events) {
                  if (e.date.year == day.year && e.date.month == day.month && e.date.day == day.day) {
                    event = e;
                    break;
                  }
                }
                final action = event?.actionKey ?? 'rest';
                final color = _colorFor(action);
                final dayName = _weekDays[day.weekday - 1];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (event?.note != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(event!.note!),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayName,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday ? CropDocColors.primary : CropDocColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isToday ? CropDocColors.primary : CropDocColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? color
                                : action == 'rest'
                                    ? CropDocColors.divider.withValues(alpha: 0.5)
                                    : color.withValues(alpha: 0.12),
                            border: isToday
                                ? Border.all(color: color, width: 2)
                                : null,
                            boxShadow: isToday && event?.isUrgent == true
                                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)]
                                : null,
                          ),
                          child: Icon(
                            _iconFor(action),
                            size: 16,
                            color: isToday ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Harvest window note
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CropDocColors.safeLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.agriculture_rounded, size: 16, color: CropDocColors.safe),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(context, 'harvest_window'),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF2D6A4F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
