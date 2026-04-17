import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../services/scan_history_service.dart';

/// Field health map — a 4x6 grid derived from actual scan history.
/// More disease scans = more red/yellow zones. Healthy history = green.
class FieldHealthMap extends StatelessWidget {
  const FieldHealthMap({super.key});

  List<Color> _computeCellColors() {
    final records = ScanHistoryService.instance.records;
    final rng = Random(42);

    // Calculate health ratio from actual data
    final total = records.length;
    final diseased = records.where((r) => r.diseaseName != 'Healthy').length;
    final resolved = records.where((r) => r.status == 'resolved').length;

    // Health percentages drive the grid colors
    double healthyPct = total > 0 ? (total - diseased) / total : 0.7;
    double resolvedPct = total > 0 ? resolved / total : 0.0;
    // Resolved diseases mean the field is recovering
    double effectiveHealthy = healthyPct + (resolvedPct * 0.3);
    effectiveHealthy = effectiveHealthy.clamp(0.0, 1.0);

    double dangerPct = total > 0
        ? records.where((r) => r.diseaseName != 'Healthy' && r.status == 'active').length / total
        : 0.05;
    double watchPct = 1.0 - effectiveHealthy - dangerPct;
    watchPct = watchPct.clamp(0.0, 1.0);

    return List.generate(24, (i) {
      final roll = rng.nextDouble();
      if (roll < effectiveHealthy * 0.7) return CropDocColors.safe;
      if (roll < effectiveHealthy) return CropDocColors.safe.withValues(alpha: 0.6);
      if (roll < effectiveHealthy + watchPct) return CropDocColors.warning;
      return CropDocColors.danger;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cellColors = _computeCellColors();
    final records = ScanHistoryService.instance.records;
    final total = records.length;
    final activeCount = records.where((r) => r.status == 'active').length;

    // Summary text
    final summaryText = activeCount > 0
        ? '$activeCount active ${activeCount == 1 ? "issue" : "issues"}'
        : total > 0
            ? 'All clear'
            : 'No data yet';

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
              const Icon(Icons.grid_view_rounded,
                  size: 18, color: CropDocColors.primary),
              const SizedBox(width: 8),
              Text(
                t(context, 'field_health'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeCount > 0
                      ? CropDocColors.danger.withValues(alpha: 0.1)
                      : CropDocColors.safe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  summaryText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: activeCount > 0 ? CropDocColors.danger : CropDocColors.safe,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid
          AspectRatio(
            aspectRatio: 6 / 4,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
