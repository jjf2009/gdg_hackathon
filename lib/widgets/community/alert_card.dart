import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/community_alert.dart';

class AlertCard extends StatelessWidget {
  final CommunityAlert alert;
  const AlertCard({super.key, required this.alert});

  String _timeAgo(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}m ${t(context, 'ago')}';
    if (diff.inHours < 24) return '${diff.inHours}h ${t(context, 'ago')}';
    return '${diff.inDays}d ${t(context, 'ago')}';
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = alert.diseaseName == 'Healthy';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alert.severity.withValues(alpha: 0.15),
              border: Border.all(color: alert.severity.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                alert.farmerName.split(' ').map((w) => w[0]).take(2).join(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: alert.severity,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.farmerName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _timeAgo(context, alert.reportedAt),
                      style: GoogleFonts.outfit(fontSize: 11, color: CropDocColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle_rounded : Icons.pest_control_rounded,
                      size: 13,
                      color: alert.severity,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${alert.diseaseName} — ${alert.cropName}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: alert.severity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.villageName} • ${alert.distanceKm} km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
