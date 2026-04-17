import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../services/scan_history_service.dart';
import '../models/scan_record.dart';
import '../widgets/history/crop_timeline.dart';
import '../widgets/history/field_health_map.dart';
import '../widgets/history/stat_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedSeason = 'Rabi';

  List<ScanRecord> get _filteredRecords {
    return ScanHistoryService.instance.records.where((r) {
      if (_selectedSeason == 'Kharif') {
        return r.date.month >= 6 && r.date.month <= 11;
      } else {
        return r.date.month <= 5 || r.date.month == 12;
      }
    }).toList();
  }

  void _showRecordDetail(ScanRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecordDetailSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    final totalScans = records.length;
    final diseasesFound = records.where((r) => r.diseaseName != 'Healthy').length;
    final resolved = records.where((r) => r.status == 'resolved').length;
    final resolvedPct = totalScans > 0 ? ((resolved / totalScans) * 100).round() : 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t(context, 'crop_history'),
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(t(context, 'history_subtitle'),
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  _SeasonToggle(
                    selected: _selectedSeason,
                    onChanged: (s) => setState(() => _selectedSeason = s),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const FieldHealthMap()
                .animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '$totalScans',
                    label: t(context, 'scans'),
                    icon: Icons.center_focus_strong_rounded,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '$diseasesFound',
                    label: t(context, 'diseases'),
                    icon: Icons.bug_report_rounded,
                    accentColor: CropDocColors.warning,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: '$resolvedPct%',
                    label: t(context, 'resolved'),
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: CropDocColors.safe,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4, height: 22,
                  decoration: BoxDecoration(
                    color: CropDocColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(t(context, 'recent_scans'),
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                Text('${records.length}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: CropDocColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No scans this season',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CropTimeline(
                    records: records,
                    onRecordTap: _showRecordDetail,
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _RecordDetailSheet extends StatelessWidget {
  final ScanRecord record;
  const _RecordDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final isHealthy = record.diseaseName == 'Healthy';
    final isFilePath = record.imagePath.startsWith('/');
    return Container(
      decoration: const BoxDecoration(
        color: CropDocColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: CropDocColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          Text(t(context, 'scan_details'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: isFilePath
                ? Image.file(File(record.imagePath), height: 140, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _imageFallback())
                : Image.asset(record.imagePath, height: 140, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _imageFallback()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(record.diseaseName,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isHealthy ? CropDocColors.safe.withValues(alpha: 0.1) : CropDocColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(record.confidence * 100).toInt()}% ${t(context, 'match')}',
                  style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isHealthy ? CropDocColors.safe : CropDocColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.eco_rounded, size: 16, color: CropDocColors.textMuted),
              const SizedBox(width: 6),
              Text(record.cropName, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_rounded, size: 14, color: CropDocColors.textMuted),
              const SizedBox(width: 6),
              Text('${record.date.day}/${record.date.month}/${record.date.year}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (record.treatmentApplied != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CropDocColors.safeLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_rounded, size: 18, color: CropDocColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t(context, 'treatment_applied'), style: Theme.of(context).textTheme.bodySmall),
                        Text(record.treatmentApplied!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _imageFallback() => Container(
    height: 140,
    color: CropDocColors.primary.withValues(alpha: 0.1),
    child: const Center(
      child: Icon(Icons.eco_rounded, size: 48, color: CropDocColors.primary),
    ),
  );
}

class _SeasonToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _SeasonToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CropDocColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Kharif', 'Rabi'].map((s) {
          final isActive = selected == s;
          return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? CropDocColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(s,
                style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : CropDocColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
