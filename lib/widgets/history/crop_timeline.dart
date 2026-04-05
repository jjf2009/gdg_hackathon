import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/scan_record.dart';

class CropTimeline extends StatelessWidget {
  final List<ScanRecord> records;
  final ValueChanged<ScanRecord>? onRecordTap;

  const CropTimeline({super.key, required this.records, this.onRecordTap});

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
          onTap: onRecordTap != null ? () => onRecordTap!(record) : null,
        );
      }),
    );
  }
}

class _TimelineEntry extends StatefulWidget {
  final ScanRecord record;
  final bool isLast;
  final int index;
  final VoidCallback? onTap;

  const _TimelineEntry({
    required this.record,
    required this.isLast,
    required this.index,
    this.onTap,
  });

  @override
  State<_TimelineEntry> createState() => _TimelineEntryState();
}

class _TimelineEntryState extends State<_TimelineEntry> {
  bool _expanded = false;

  String get _monthDay {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[widget.record.date.month - 1]} ${widget.record.date.day}';
  }

  String _translateDisease(BuildContext context, String name) {
    final key = name.toLowerCase().replaceAll(' ', '_');
    final translated = t(context, key);
    return translated != key ? translated : name;
  }

  String _translateCrop(BuildContext context, String name) {
    final key = name.toLowerCase();
    final translated = t(context, key);
    return translated != key ? translated : name;
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = widget.record.diseaseName == 'Healthy';
    final isActive = widget.record.status == 'active';

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
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _monthDay,
                style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: CropDocColors.textMuted,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: [
                      if (isActive)
                        BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                if (!widget.isLast)
                  Expanded(child: Container(width: 1.5, color: CropDocColors.divider)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _expanded = !_expanded);
                widget.onTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive
                      ? CropDocColors.dangerLight.withValues(alpha: 0.5)
                      : _expanded
                          ? CropDocColors.primary.withValues(alpha: 0.04)
                          : CropDocColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? CropDocColors.danger.withValues(alpha: 0.2)
                        : _expanded
                            ? CropDocColors.primary.withValues(alpha: 0.3)
                            : CropDocColors.divider,
                    width: _expanded ? 1.0 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.record.imagePath,
                            width: 44, height: 44, fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: CropDocColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.eco_rounded, color: CropDocColors.primary, size: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _translateDisease(context, widget.record.diseaseName),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _translateCrop(context, widget.record.cropName),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(status: widget.record.status, isHealthy: isHealthy),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: CropDocColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Expanded details
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            _DetailRow(
                              icon: Icons.percent_rounded,
                              label: t(context, 'confidence'),
                              value: '${(widget.record.confidence * 100).toInt()}%',
                            ),
                            const SizedBox(height: 8),
                            _DetailRow(
                              icon: Icons.medical_services_rounded,
                              label: t(context, 'treatment_applied'),
                              value: widget.record.treatmentApplied ?? t(context, 'no_treatment'),
                            ),
                            if (!isHealthy && widget.record.status == 'active') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.local_pharmacy_rounded, size: 16),
                                  label: Text(t(context, 'view_treatment')),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: CropDocColors.textMuted),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isHealthy;
  const _StatusChip({required this.status, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    String labelKey;
    Color color;
    IconData icon;

    if (isHealthy) {
      labelKey = 'status_ok';
      color = CropDocColors.safe;
      icon = Icons.check_rounded;
    } else if (status == 'active') {
      labelKey = 'status_active';
      color = CropDocColors.danger;
      icon = Icons.warning_amber_rounded;
    } else {
      labelKey = 'status_fixed';
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
            t(context, labelKey),
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
