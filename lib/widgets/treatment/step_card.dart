import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class StepCard extends StatelessWidget {
  final String emoji;
  final String instruction;
  final String urgencyLabel;
  final String? detail;
  final int index;

  const StepCard({
    super.key,
    required this.emoji,
    required this.instruction,
    required this.urgencyLabel,
    this.detail,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color urgencyColor;
    switch (urgencyLabel.toLowerCase()) {
      case 'do today':
        urgencyColor = CropDocColors.danger;
        break;
      case 'this week':
        urgencyColor = CropDocColors.warning;
        break;
      default:
        urgencyColor = CropDocColors.primaryLight;
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        // Slight left offset variation to break symmetry
        left: index == 1 ? 4.0 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CropDocColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.4,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    urgencyLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: urgencyColor,
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
