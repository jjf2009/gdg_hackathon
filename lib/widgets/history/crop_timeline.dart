import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../models/scan_record.dart';

class CropTimeline extends StatelessWidget {
  final List<ScanRecord> records;

  const CropTimeline({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(records.length, (i) {
        final record = records[i];
        final isLast = i == records.length - 1;
        return _TimelineEntry(
          record: record,
          isLast: isLast,
          index: i,
        );
      }),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final ScanRecord record;
  final bool isLast;
  final int index;

  const _TimelineEntry({
    required this.record,
    required this.isLast,
    required this.index,
  });

  String get _monthDay {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[record.date.month - 1]} ${record.date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = record.diseaseName == 'Healthy';
    final isActive = record.status == 'active';

    Color dotColor;
    if (isHealthy) {
      dotColor = CropDocColors.safe;
    } else if (isActive) {
      dotColor = CropDocColors.danger;
    } else {
      dotColor = CropDocColors.primaryLight;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date column
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _monthDay,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CropDocColors.textMuted,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Timeline line + dot
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: CropDocColors.divider,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isActive
                    ? CropDocColors.dangerLight.withValues(alpha: 0.5)
                    : CropDocColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? CropDocColors.danger.withValues(alpha: 0.2)
                      : CropDocColors.divider,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      record.imagePath,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CropDocColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: CropDocColors.primary, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.diseaseName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.cropName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    status: record.status,
                    isHealthy: isHealthy,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isHealthy;

  const _StatusChip({required this.status, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    if (isHealthy) {
      label = 'OK';
      color = CropDocColors.safe;
      icon = Icons.check_rounded;
    } else if (status == 'active') {
      label = 'Active';
      color = CropDocColors.danger;
      icon = Icons.warning_amber_rounded;
    } else {
      label = 'Fixed';
      color = CropDocColors.primaryLight;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
