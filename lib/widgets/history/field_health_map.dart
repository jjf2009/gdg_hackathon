import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../services/scan_history_service.dart';

/// Descriptive, interactive field health map driven by actual scan data.
class FieldHealthMap extends StatelessWidget {
  const FieldHealthMap({super.key});

  @override
  Widget build(BuildContext context) {
    final records = ScanHistoryService.instance.records;
    final total = records.length;
    final healthy = records.where((r) => r.diseaseName == 'Healthy').length;
    final active = records.where((r) => r.diseaseName != 'Healthy' && r.status == 'active').length;
    final resolved = records.where((r) => r.status == 'resolved').length;
    final treated = records.where((r) => r.treatmentApplied != null).length;

    // Compute cell colors from scan history
    final cellColors = _computeCellColors(total, healthy, active, resolved);

    // Health score 0-100
    final healthScore = total > 0
        ? ((healthy + resolved) / total * 100).round()
        : 100;

    // Color for health score
    final scoreColor = healthScore > 75 ? CropDocColors.safe
        : healthScore > 40 ? CropDocColors.warning
        : CropDocColors.danger;

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
          // Header with health score
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, size: 18, color: CropDocColors.primary),
              const SizedBox(width: 8),
              Text(t(context, 'field_health'), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              // Health score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      healthScore > 75 ? Icons.favorite_rounded
                          : healthScore > 40 ? Icons.warning_amber_rounded
                          : Icons.error_rounded,
                      size: 14, color: scoreColor,
                    ),
                    const SizedBox(width: 4),
                    Text('$healthScore%',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: scoreColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _MiniStat(icon: Icons.center_focus_strong_rounded, value: '$total', label: t(context, 'scans'), color: CropDocColors.primary),
              _MiniStat(icon: Icons.eco_rounded, value: '$healthy', label: t(context, 'healthy'), color: CropDocColors.safe),
              _MiniStat(icon: Icons.bug_report_rounded, value: '$active', label: t(context, 'active'), color: CropDocColors.danger),
              _MiniStat(icon: Icons.medical_services_rounded, value: '$treated', label: t(context, 'treated'), color: CropDocColors.primary),
            ],
          ),
          const SizedBox(height: 14),

          // Grid
          AspectRatio(
            aspectRatio: 6 / 4,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, mainAxisSpacing: 3, crossAxisSpacing: 3,
              ),
              itemCount: 24,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    final zone = 'Zone ${(i ~/ 6) + 1}-${(i % 6) + 1}';
                    final status = cellColors[i] == CropDocColors.danger
                        ? t(context, 'affected')
                        : cellColors[i] == CropDocColors.warning
                            ? t(context, 'watch')
                            : t(context, 'healthy');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$zone: $status'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColors[i],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: CropDocColors.safe, label: t(context, 'healthy')),
              const SizedBox(width: 16),
              _LegendDot(color: CropDocColors.warning, label: t(context, 'watch')),
              const SizedBox(width: 16),
              _LegendDot(color: CropDocColors.danger, label: t(context, 'affected')),
            ],
          ),

          // Summary text
          if (total > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor.withValues(alpha: 0.15)),
              ),
              child: Text(
                active > 0
                    ? '$active active ${active == 1 ? "issue" : "issues"} detected. ${resolved > 0 ? "$resolved resolved. " : ""}Follow treatment plan.'
                    : total > 0 && healthy == total
                        ? 'All $total scans healthy! Your field is in great condition.'
                        : '$resolved of ${total - healthy} issues resolved. Keep monitoring.',
                style: GoogleFonts.outfit(fontSize: 11, color: scoreColor, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _computeCellColors(int total, int healthy, int active, int resolved) {
    final rng = Random(42);
    double healthyPct = total > 0 ? (healthy + resolved) / total : 0.7;
    healthyPct = healthyPct.clamp(0.2, 0.95);
    double dangerPct = total > 0 ? active / total : 0.05;
    dangerPct = dangerPct.clamp(0.0, 0.5);

    return List.generate(24, (i) {
      final roll = rng.nextDouble();
      if (roll < healthyPct * 0.65) return CropDocColors.safe;
      if (roll < healthyPct) return CropDocColors.safe.withValues(alpha: 0.6);
      if (roll < healthyPct + (1 - healthyPct - dangerPct)) return CropDocColors.warning;
      return CropDocColors.danger;
    });
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: CropDocColors.textPrimary)),
          Text(label, style: GoogleFonts.outfit(fontSize: 9, color: CropDocColors.textMuted)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}
