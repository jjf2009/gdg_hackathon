import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/calendar_event.dart';

class SprayCalendar extends StatefulWidget {
  final List<CalendarEvent> events;
  const SprayCalendar({super.key, required this.events});

  @override
  State<SprayCalendar> createState() => _SprayCalendarState();
}

class _SprayCalendarState extends State<SprayCalendar> {
  bool _expanded = false;

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

  String _actionLabel(String action) {
    switch (action) {
      case 'spray': return 'Spray';
      case 'check': case 'recheck': return 'Check';
      case 'harvest': return 'Harvest';
      case 'rest': return 'Rest';
      default: return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Show 7 days in strip
    final days = List.generate(7, (i) => today.add(Duration(days: i)));
    // All events sorted for expanded view
    final allEvents = List<CalendarEvent>.from(widget.events)
      ..sort((a, b) => a.date.compareTo(b.date));

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
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: CropDocColors.primary),
                const SizedBox(width: 8),
                Text(t(context, 'spray_schedule'), style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('${allEvents.where((e) => e.actionKey != 'rest').length} tasks',
                  style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded, size: 20, color: CropDocColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 7-day strip (always visible)
          SizedBox(
            height: 88,
            child: Row(
              children: days.map((day) {
                final isToday = day == today;
                CalendarEvent? event;
                for (final e in widget.events) {
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
                        Text(dayName, style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? CropDocColors.primary : CropDocColors.textMuted,
                        )),
                        const SizedBox(height: 4),
                        Text('${day.day}', style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: isToday ? CropDocColors.primary : CropDocColors.textPrimary,
                        )),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: event?.isCompleted == true ? CropDocColors.safeLight : (isToday ? color
                                : action == 'rest' ? CropDocColors.divider.withValues(alpha: 0.5)
                                : color.withValues(alpha: 0.12)),
                            border: isToday && !(event?.isCompleted == true) ? Border.all(color: color, width: 2) : null,
                            boxShadow: isToday && event?.isUrgent == true && !(event?.isCompleted == true)
                                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)]
                                : null,
                          ),
                          child: Icon(event?.isCompleted == true ? Icons.check_circle_rounded : _iconFor(action), size: 16,
                            color: event?.isCompleted == true ? CropDocColors.safe : (isToday ? Colors.white : color)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Expanded full schedule
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 20),
                Text('Full Treatment Schedule', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...allEvents.where((e) => e.actionKey != 'rest').map((event) {
                  final isPast = event.date.isBefore(today);
                  final isEventToday = event.date == today;
                  final color = _colorFor(event.actionKey);
                  final daysFromNow = event.date.difference(today).inDays;
                  final dayLabel = isEventToday ? 'Today'
                      : daysFromNow == 1 ? 'Tomorrow'
                      : daysFromNow < 0 ? '${-daysFromNow}d ago'
                      : 'Day $daysFromNow';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPast || event.isCompleted
                          ? CropDocColors.divider.withValues(alpha: 0.3)
                          : color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isEventToday && !event.isCompleted ? color : color.withValues(alpha: 0.15),
                        width: isEventToday && !event.isCompleted ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: event.isCompleted ? CropDocColors.safe.withValues(alpha: 0.15) : color.withValues(alpha: isPast ? 0.1 : 0.15),
                          ),
                          child: Icon(event.isCompleted ? Icons.check_circle_rounded : _iconFor(event.actionKey), size: 16, color: event.isCompleted ? CropDocColors.safe : color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_actionLabel(event.actionKey),
                                style: GoogleFonts.outfit(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: isPast || event.isCompleted ? CropDocColors.textMuted : CropDocColors.textPrimary,
                                  decoration: isPast || event.isCompleted ? TextDecoration.lineThrough : null,
                                )),
                              if (event.note != null)
                                Text(event.note!, style: GoogleFonts.outfit(
                                  fontSize: 11, color: event.isCompleted ? CropDocColors.safe : CropDocColors.textMuted),
                                  maxLines: event.isCompleted ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isEventToday && !event.isCompleted ? color.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(dayLabel, style: GoogleFonts.outfit(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isEventToday && !event.isCompleted ? color : CropDocColors.textMuted)),
                        ),
                        if (event.isUrgent)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(Icons.priority_high_rounded, size: 16, color: CropDocColors.danger),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 200.ms);
                }),
              ],
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // Tap to expand hint
          if (!_expanded) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Container(
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
                      child: Text(t(context, 'harvest_window'),
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2D6A4F), fontWeight: FontWeight.w500)),
                    ),
                    const Icon(Icons.expand_more_rounded, size: 16, color: CropDocColors.safe),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
