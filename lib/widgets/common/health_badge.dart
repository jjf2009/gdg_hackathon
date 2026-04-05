import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HealthBadge extends StatelessWidget {
  final String severity;
  final double? fontSize;

  const HealthBadge({
    super.key,
    required this.severity,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (severity) {
      case 'critical':
        label = 'Critical';
        bgColor = CropDocColors.danger;
        textColor = Colors.white;
        icon = Icons.error_rounded;
        break;
      case 'high':
        label = 'Needs Attention';
        bgColor = const Color(0xFFE85D5D);
        textColor = Colors.white;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        label = 'Monitor';
        bgColor = CropDocColors.warning;
        textColor = const Color(0xFF5C4A00);
        icon = Icons.visibility_rounded;
        break;
      default:
        label = 'Healthy';
        bgColor = CropDocColors.safe;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontSize: fontSize ?? 14,
                ),
          ),
        ],
      ),
    );
  }
}
