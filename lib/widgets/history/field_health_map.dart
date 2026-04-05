import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Abstract mini field-health map — a 4×6 grid of colored cells
/// representing zones of a field. Colors are randomized but weighted
/// toward green (healthy) with a few yellow/red danger spots.
class FieldHealthMap extends StatelessWidget {
  const FieldHealthMap({super.key});

  static final _rng = Random(42); // Fixed seed for consistent display

  static final List<Color> _cellColors = List.generate(24, (i) {
    final roll = _rng.nextDouble();
    if (roll < 0.55) return CropDocColors.safe;
    if (roll < 0.75) return CropDocColors.safe.withValues(alpha: 0.6);
    if (roll < 0.88) return CropDocColors.warning;
    return CropDocColors.danger;
  });

  @override
  Widget build(BuildContext context) {
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
                'Field Health',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                'Plot A — 1.2 ha',
                style: Theme.of(context).textTheme.bodySmall,
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
                return Container(
                  decoration: BoxDecoration(
                    color: _cellColors[i],
                    borderRadius: BorderRadius.circular(4),
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
              _LegendDot(color: CropDocColors.safe, label: 'Healthy'),
              const SizedBox(width: 16),
              _LegendDot(color: CropDocColors.warning, label: 'Watch'),
              const SizedBox(width: 16),
              _LegendDot(color: CropDocColors.danger, label: 'Affected'),
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
