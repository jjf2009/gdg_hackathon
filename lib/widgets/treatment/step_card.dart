import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class StepCard extends StatefulWidget {
  final IconData icon;
  final String instruction;
  final String urgencyLabel;
  final String? detail;
  final int index;

  const StepCard({
    super.key,
    required this.icon,
    required this.instruction,
    required this.urgencyLabel,
    this.detail,
    this.index = 0,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    Color urgencyColor;
    switch (widget.urgencyLabel.toLowerCase()) {
      case 'do today':
        urgencyColor = CropDocColors.danger;
        break;
      case 'urgent':
        urgencyColor = CropDocColors.danger;
        break;
      case 'this week':
        urgencyColor = CropDocColors.warning;
        break;
      default:
        urgencyColor = CropDocColors.primaryLight;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: 10,
        left: widget.index == 1 ? 4.0 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _completed
            ? CropDocColors.safeLight.withValues(alpha: 0.5)
            : CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _completed ? CropDocColors.safe.withValues(alpha: 0.4) : CropDocColors.divider,
          width: _completed ? 1.2 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.textPrimary.withValues(alpha: _completed ? 0.01 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _completed = !_completed);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _completed
                    ? CropDocColors.safe
                    : CropDocColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Icon(
                  _completed ? Icons.check_rounded : widget.icon,
                  size: 20,
                  color: _completed ? Colors.white : CropDocColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.instruction,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.35,
                        decoration: _completed ? TextDecoration.lineThrough : null,
                        color: _completed ? CropDocColors.textMuted : null,
                      ),
                ),
                if (widget.detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.detail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.4,
                          color: _completed ? CropDocColors.textMuted : null,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _completed
                            ? CropDocColors.safe.withValues(alpha: 0.1)
                            : urgencyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _completed ? '✓ Done' : widget.urgencyLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _completed ? CropDocColors.safe : urgencyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
