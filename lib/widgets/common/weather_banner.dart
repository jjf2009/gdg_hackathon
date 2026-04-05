import 'package:flutter/material.dart';
import '../../config/theme.dart';

class WeatherBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final String riskLevel;

  const WeatherBanner({
    super.key,
    required this.icon,
    required this.message,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    switch (riskLevel) {
      case 'high':
        bgColor = const Color(0xFFFFF0D4);
        textColor = const Color(0xFF8B6914);
        break;
      case 'medium':
        bgColor = CropDocColors.warningLight;
        textColor = const Color(0xFF8B7A2B);
        break;
      default:
        bgColor = CropDocColors.safeLight;
        textColor = const Color(0xFF2D6A4F);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
            ),
          ),
          if (riskLevel == 'high')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Alert',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
