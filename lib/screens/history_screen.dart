import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../data/dummy_history.dart';
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crop History',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your field health over time',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Season toggle
                  _SeasonToggle(
                    selected: _selectedSeason,
                    onChanged: (s) => setState(() => _selectedSeason = s),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Field health map
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const FieldHealthMap()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, duration: 400.ms),
          ),
        ),

        // Stats row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                StatCard(
                  value: '${DummyHistory.totalScans}',
                  label: 'Scans',
                  icon: Icons.center_focus_strong_rounded,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms)
                    .slideY(begin: 0.1, duration: 300.ms),
                const SizedBox(width: 10),
                StatCard(
                  value: '${DummyHistory.diseasesFound}',
                  label: 'Diseases',
                  icon: Icons.bug_report_rounded,
                  accentColor: CropDocColors.warning,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 300.ms)
                    .slideY(begin: 0.1, duration: 300.ms),
                const SizedBox(width: 10),
                StatCard(
                  value: '${DummyHistory.resolvedPercent}%',
                  label: 'Resolved',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: CropDocColors.safe,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 300.ms)
                    .slideY(begin: 0.1, duration: 300.ms),
              ],
            ),
          ),
        ),

        // Timeline header
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: CropDocColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Recent Scans',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),

        // Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CropTimeline(records: DummyHistory.records)
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? CropDocColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
