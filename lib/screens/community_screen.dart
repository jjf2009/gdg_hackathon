import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../data/dummy_community.dart';
import '../services/scan_history_service.dart';
import '../models/community_alert.dart';
import '../widgets/community/disease_map.dart';
import '../widgets/community/alert_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<CommunityAlert> _userReports = [];

  /// Auto-generate alert from latest scan if it detected a disease
  List<CommunityAlert> get _autoAlerts {
    final records = ScanHistoryService.instance.records;
    final alerts = <CommunityAlert>[];
    for (final r in records) {
      if (r.diseaseName != 'Healthy') {
        alerts.add(CommunityAlert(
          farmerName: t(context, 'you'),
          villageName: 'Baramati',
          diseaseName: r.diseaseName,
          cropName: r.cropName,
          distanceKm: 0.0,
          reportedAt: r.date,
          mapX: 0.48, mapY: 0.45,
          severity: CropDocColors.danger,
        ));
      }
    }
    return alerts;
  }

  List<CommunityAlert> get _allAlerts => [..._userReports, ..._autoAlerts, ...DummyCommunity.alerts];
  List<CommunityAlert> get _diseaseAlerts =>
      _allAlerts.where((a) => a.diseaseName != 'Healthy').toList();

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ReportDiseaseSheet(
        onSubmit: (alert) {
          setState(() => _userReports.insert(0, alert));
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t(context, 'report_submitted')),
              behavior: SnackBarBehavior.floating,
              backgroundColor: CropDocColors.safe,
            ),
          );
        },
      ),
    );
  }

  void _showSubmitReportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _DetailedReportSheet(
        onSubmit: (reportData) {
          // Create a community alert from the detailed report
          setState(() => _userReports.insert(0, CommunityAlert(
            farmerName: reportData['farmer_name'] ?? t(context, 'you'),
            villageName: reportData['location'] ?? 'Unknown',
            diseaseName: reportData['suspected_disease'] ?? 'Unknown',
            cropName: reportData['crop_name'] ?? 'Unknown',
            distanceKm: 0.0,
            reportedAt: DateTime.now(),
            mapX: 0.48, mapY: 0.45,
            severity: CropDocColors.danger,
          )));
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t(context, 'report_submitted')),
              behavior: SnackBarBehavior.floating,
              backgroundColor: CropDocColors.safe,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAlerts = _allAlerts;
    final diseaseAlerts = _diseaseAlerts;
    // Compute trends dynamically from all alerts
    final trendMap = <String, int>{};
    for (final a in diseaseAlerts) {
      trendMap[a.diseaseName] = (trendMap[a.diseaseName] ?? 0) + 1;
    }
    final sortedDiseases = trendMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final trends = sortedDiseases.take(3).map((e) {
      final count = e.value;
      return DiseaseTrend(
        diseaseName: e.key,
        reportsThisWeek: count,
        changePercent: count > 5 ? 40 : (count > 2 ? 10 : -20),
        icon: count > 5 ? Icons.trending_up_rounded
            : count > 2 ? Icons.trending_flat_rounded
            : Icons.trending_down_rounded,
      );
    }).toList();
    if (trends.isEmpty) {
      trends.addAll(DummyCommunity.trends);
    }
    final totalReports = diseaseAlerts.length;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t(context, 'community_alerts'),
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 2),
                      Text(t(context, 'community_subtitle'),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),

            // Alert summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      CropDocColors.danger.withValues(alpha: 0.08),
                      CropDocColors.warning.withValues(alpha: 0.06),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CropDocColors.danger.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: CropDocColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('$totalReports',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700,
                              color: CropDocColors.danger)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t(context, 'reports_near_you'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: CropDocColors.danger)),
                            Text(t(context, 'this_week_5km'),
                              style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications_active_rounded,
                          color: CropDocColors.danger, size: 22),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
              ),
            ),

            // Disease map
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: DiseaseMap(alerts: allAlerts)
                    .animate().fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.05, duration: 400.ms),
              ),
            ),

            // Trending diseases
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 22,
                      decoration: BoxDecoration(color: CropDocColors.warning, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(t(context, 'trending_diseases'),
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: trends.map((trend) {
                    final isUp = trend.changePercent > 0;
                    final color = isUp ? CropDocColors.danger : CropDocColors.safe;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CropDocColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CropDocColors.divider, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Icon(trend.icon, color: color, size: 20),
                            const SizedBox(height: 6),
                            Text('${trend.reportsThisWeek}',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700,
                                color: CropDocColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(trend.diseaseName,
                              style: GoogleFonts.outfit(fontSize: 10, color: CropDocColors.textMuted),
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${isUp ? '+' : ''}${trend.changePercent}%',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ),
            ),

            // Emergency Helpline Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 22,
                      decoration: BoxDecoration(color: CropDocColors.danger, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(t(context, 'community_helpline'),
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _HelplineCard(
                      icon: Icons.agriculture_rounded,
                      title: t(context, 'community_helpline_kvk'),
                      subtitle: t(context, 'community_helpline_kvk_subtitle'),
                      phone: '1800-180-1551',
                    ),
                    const SizedBox(height: 8),
                    _HelplineCard(
                      icon: Icons.support_agent_rounded,
                      title: t(context, 'community_helpline_kcc'),
                      subtitle: t(context, 'community_helpline_kcc_subtitle'),
                      phone: '1800-180-1551',
                    ),
                    const SizedBox(height: 8),
                    _HelplineCard(
                      icon: Icons.local_hospital_rounded,
                      title: t(context, 'community_helpline_ppa'),
                      subtitle: t(context, 'community_helpline_ppa_subtitle'),
                      phone: '020-26123456',
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ),
            ),

            // Recent reports header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 22,
                      decoration: BoxDecoration(color: CropDocColors.primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(t(context, 'recent_reports'),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const Spacer(),
                    Text('${diseaseAlerts.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),

            // Alert cards — user reports first (with "You" badge), then community
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final alert = diseaseAlerts[i];
                    final isUserReport = _userReports.contains(alert);
                    return _WrappedAlertCard(
                      alert: alert,
                      isUserReport: isUserReport,
                    ).animate()
                        .fadeIn(delay: Duration(milliseconds: 600 + i * 80), duration: 300.ms)
                        .slideX(begin: 0.05, duration: 300.ms);
                  },
                  childCount: diseaseAlerts.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // FAB row: Report Disease + Submit Report
        Positioned(
          bottom: 24, right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Submit Report button (new)
              GestureDetector(
                onTap: _showSubmitReportSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: CropDocColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CropDocColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Submit Report',
                        style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Report Disease button (existing)
              GestureDetector(
                onTap: _showReportSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: CropDocColors.danger,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CropDocColors.danger.withValues(alpha: 0.35),
                        blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_alert_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        t(context, 'report_disease'),
                        style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Alert card wrapper that shows "You" badge on user-submitted reports
class _WrappedAlertCard extends StatelessWidget {
  final CommunityAlert alert;
  final bool isUserReport;
  const _WrappedAlertCard({required this.alert, required this.isUserReport});

  @override
  Widget build(BuildContext context) {
    if (!isUserReport) return AlertCard(alert: alert);

    return Stack(
      children: [
        AlertCard(alert: alert),
        Positioned(
          top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CropDocColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              t(context, 'you'),
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for reporting a disease
class _ReportDiseaseSheet extends StatefulWidget {
  final ValueChanged<CommunityAlert> onSubmit;
  const _ReportDiseaseSheet({required this.onSubmit});

  @override
  State<_ReportDiseaseSheet> createState() => _ReportDiseaseSheetState();
}

class _ReportDiseaseSheetState extends State<_ReportDiseaseSheet> {
  String _selectedCrop = 'Tomato';
  String _selectedDisease = 'Early Blight';

  // From PlantVillage dataset — actual crops the model recognizes
  static const Map<String, List<String>> _cropDiseases = {
    'Apple': ['Apple Scab', 'Black Rot', 'Cedar Apple Rust'],
    'Cherry': ['Powdery Mildew'],
    'Corn': ['Cercospora Leaf Spot', 'Common Rust', 'Northern Leaf Blight'],
    'Grape': ['Black Rot', 'Esca', 'Leaf Blight'],
    'Orange': ['Haunglongbing'],
    'Peach': ['Bacterial Spot'],
    'Pepper': ['Bacterial Spot'],
    'Potato': ['Early Blight', 'Late Blight'],
    'Squash': ['Powdery Mildew'],
    'Strawberry': ['Leaf Scorch'],
    'Tomato': ['Bacterial Spot', 'Early Blight', 'Late Blight', 'Leaf Mold',
               'Septoria Leaf Spot', 'Spider Mites', 'Target Spot',
               'Yellow Leaf Curl Virus', 'Mosaic Virus'],
  };

  List<String> get _crops => _cropDiseases.keys.toList();
  List<String> get _diseases => _cropDiseases[_selectedCrop] ?? [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CropDocColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: CropDocColors.divider, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(t(context, 'report_disease'),
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(t(context, 'report_help_text'),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),

          // Crop selector
          Text(t(context, 'select_crop'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _crops.map((crop) {
              final isSelected = crop == _selectedCrop;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCrop = crop;
                  final diseases = _cropDiseases[crop] ?? [];
                  if (!diseases.contains(_selectedDisease) && diseases.isNotEmpty) {
                    _selectedDisease = diseases.first;
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CropDocColors.primary : CropDocColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CropDocColors.primary : CropDocColors.divider, width: isSelected ? 1.5 : 0.5),
                  ),
                  child: Text(
                    t(context, crop.toLowerCase()),
                    style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : CropDocColors.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Disease selector
          Text(t(context, 'select_disease'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _diseases.map((disease) {
              final isSelected = disease == _selectedDisease;
              final key = disease.toLowerCase().replaceAll(' ', '_');
              final label = t(context, key);
              return GestureDetector(
                onTap: () => setState(() => _selectedDisease = disease),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CropDocColors.danger : CropDocColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CropDocColors.danger : CropDocColors.divider, width: isSelected ? 1.5 : 0.5),
                  ),
                  child: Text(
                    label != key ? label : disease,
                    style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : CropDocColors.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSubmit(CommunityAlert(
                  farmerName: t(context, 'you'),
                  villageName: 'Baramati',
                  diseaseName: _selectedDisease,
                  cropName: _selectedCrop,
                  distanceKm: 0.0,
                  reportedAt: DateTime.now(),
                  mapX: 0.48, mapY: 0.45,
                  severity: CropDocColors.danger,
                ));
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(t(context, 'submit_report')),
              style: ElevatedButton.styleFrom(
                backgroundColor: CropDocColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String phone;

  const _HelplineCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: CropDocColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: CropDocColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:$phone')),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CropDocColors.safe,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(phone, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detailed report form — structured for RAG pipeline consumption
class _DetailedReportSheet extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSubmit;
  const _DetailedReportSheet({required this.onSubmit});

  @override
  State<_DetailedReportSheet> createState() => _DetailedReportSheetState();
}

class _DetailedReportSheetState extends State<_DetailedReportSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _farmerNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _symptomCtrl = TextEditingController();
  final _treatmentTriedCtrl = TextEditingController();
  final _daysOnsetCtrl = TextEditingController();
  final _affectedAreaCtrl = TextEditingController();
  final _additionalNotesCtrl = TextEditingController();

  // Selectable values
  String _selectedCrop = 'Tomato';
  String _selectedGrowthStage = 'Vegetative';
  String _selectedDisease = 'Unknown / Not Sure';
  String _selectedWeather = 'Humid';
  String _selectedSoilType = 'Loamy';
  String _selectedIrrigation = 'Drip';
  String _selectedSeverity = 'Moderate';

  static const List<String> _crops = [
    'Tomato', 'Potato', 'Wheat', 'Corn', 'Cotton', 'Soybean',
    'Rice', 'Onion', 'Grape', 'Apple', 'Cherry', 'Pepper', 'Other',
  ];

  static const List<String> _growthStages = [
    'Seedling', 'Vegetative', 'Flowering', 'Fruiting', 'Mature / Harvest',
  ];

  static const List<String> _diseases = [
    'Unknown / Not Sure', 'Early Blight', 'Late Blight',
    'Powdery Mildew', 'Bacterial Spot', 'Leaf Curl',
    'Root Rot', 'Mosaic Virus', 'Black Rot', 'Leaf Scorch',
    'Septoria Leaf Spot', 'Common Rust', 'Downy Mildew', 'Other',
  ];

  static const List<String> _weatherOptions = [
    'Humid', 'Dry / Hot', 'Rainy', 'Foggy / Misty', 'Cold', 'Normal',
  ];

  static const List<String> _soilTypes = [
    'Loamy', 'Sandy', 'Clay', 'Black Cotton Soil', 'Red Soil', 'Other',
  ];

  static const List<String> _irrigationTypes = [
    'Drip', 'Flood', 'Sprinkler', 'Rain-fed', 'Manual Watering', 'None',
  ];

  static const List<String> _severityLevels = [
    'Mild (few spots)', 'Moderate (spreading)', 'Severe (major damage)', 'Critical (plant dying)',
  ];

  @override
  void dispose() {
    _farmerNameCtrl.dispose();
    _locationCtrl.dispose();
    _symptomCtrl.dispose();
    _treatmentTriedCtrl.dispose();
    _daysOnsetCtrl.dispose();
    _affectedAreaCtrl.dispose();
    _additionalNotesCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = <String, String>{
      'farmer_name': _farmerNameCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'crop_name': _selectedCrop,
      'growth_stage': _selectedGrowthStage,
      'suspected_disease': _selectedDisease,
      'symptom_description': _symptomCtrl.text.trim(),
      'severity': _selectedSeverity,
      'affected_area_percent': _affectedAreaCtrl.text.trim(),
      'days_since_onset': _daysOnsetCtrl.text.trim(),
      'weather_conditions': _selectedWeather,
      'soil_type': _selectedSoilType,
      'irrigation_type': _selectedIrrigation,
      'treatments_tried': _treatmentTriedCtrl.text.trim(),
      'additional_notes': _additionalNotesCtrl.text.trim(),
      'submitted_at': DateTime.now().toIso8601String(),
    };

    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: CropDocColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: CropDocColors.divider, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CropDocColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded, color: CropDocColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Submit Detailed Report',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700,
                              color: CropDocColors.textPrimary)),
                          Text('Complete field observation for expert analysis',
                            style: GoogleFonts.outfit(fontSize: 12, color: CropDocColors.textMuted)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: CropDocColors.textMuted, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: CropDocColors.divider),
              ],
            ),
          ),
          // Scrollable form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Basic Info ──
                    _sectionHeader(Icons.person_outline_rounded, 'Basic Information'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _farmerNameCtrl,
                      label: 'Your Name',
                      hint: 'E.g., Ramesh Kumar',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _locationCtrl,
                      label: 'Village / Location',
                      hint: 'E.g., Baramati, Pune District',
                      icon: Icons.location_on_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                    ),

                    const SizedBox(height: 24),

                    // ── Section: Crop Details ──
                    _sectionHeader(Icons.grass_rounded, 'Crop Details'),
                    const SizedBox(height: 12),
                    _buildChipSelector(
                      label: 'Crop',
                      options: _crops,
                      selected: _selectedCrop,
                      onSelect: (v) => setState(() => _selectedCrop = v),
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Growth Stage',
                      options: _growthStages,
                      selected: _selectedGrowthStage,
                      onSelect: (v) => setState(() => _selectedGrowthStage = v),
                    ),

                    const SizedBox(height: 24),

                    // ── Section: Disease Observation ──
                    _sectionHeader(Icons.biotech_rounded, 'Disease Observation'),
                    const SizedBox(height: 12),
                    _buildChipSelector(
                      label: 'Suspected Disease',
                      options: _diseases,
                      selected: _selectedDisease,
                      onSelect: (v) => setState(() => _selectedDisease = v),
                      color: CropDocColors.danger,
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Severity Level',
                      options: _severityLevels,
                      selected: _selectedSeverity,
                      onSelect: (v) => setState(() => _selectedSeverity = v),
                      color: CropDocColors.warning,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _symptomCtrl,
                      label: 'Describe Symptoms in Detail',
                      hint: 'E.g., Brown circular spots with concentric rings on lower leaves. Yellowing around spots spreading upward. Some leaves wilting...',
                      icon: Icons.edit_note_rounded,
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().length < 10) ? 'Please describe symptoms (min 10 chars)' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _affectedAreaCtrl,
                            label: 'Affected Area (%)',
                            hint: 'E.g., 30',
                            icon: Icons.pie_chart_outline_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _daysOnsetCtrl,
                            label: 'Days Since Onset',
                            hint: 'E.g., 5',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Section: Environment ──
                    _sectionHeader(Icons.cloud_outlined, 'Environmental Conditions'),
                    const SizedBox(height: 12),
                    _buildChipSelector(
                      label: 'Recent Weather',
                      options: _weatherOptions,
                      selected: _selectedWeather,
                      onSelect: (v) => setState(() => _selectedWeather = v),
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Soil Type',
                      options: _soilTypes,
                      selected: _selectedSoilType,
                      onSelect: (v) => setState(() => _selectedSoilType = v),
                      color: const Color(0xFF92400E),
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Irrigation Method',
                      options: _irrigationTypes,
                      selected: _selectedIrrigation,
                      onSelect: (v) => setState(() => _selectedIrrigation = v),
                      color: const Color(0xFF0891B2),
                    ),

                    const SizedBox(height: 24),

                    // ── Section: Treatments ──
                    _sectionHeader(Icons.medication_rounded, 'Treatments Already Tried'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _treatmentTriedCtrl,
                      label: 'What have you tried so far?',
                      hint: 'E.g., Sprayed Mancozeb 2 days ago, removed affected leaves, applied neem oil...',
                      icon: Icons.science_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // ── Section: Additional Notes ──
                    _sectionHeader(Icons.sticky_note_2_outlined, 'Additional Notes'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _additionalNotesCtrl,
                      label: 'Any other observations',
                      hint: 'E.g., Same issue seen in neighbouring fields. Using organic fertilizer. Crops were transplanted 45 days ago...',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: Text('Submit Report',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CropDocColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CropDocColors.primary),
        const SizedBox(width: 8),
        Text(title,
          style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: CropDocColors.textPrimary, letterSpacing: -0.3)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: CropDocColors.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(fontSize: 14, color: CropDocColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(fontSize: 13, color: CropDocColors.textMuted),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, size: 18, color: CropDocColors.textMuted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            filled: true,
            fillColor: CropDocColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: CropDocColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: CropDocColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: CropDocColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: CropDocColors.danger),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
    Color color = CropDocColors.primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: CropDocColors.textSecondary, letterSpacing: 0.3)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? color : CropDocColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : CropDocColors.divider,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 6, offset: const Offset(0, 2)),
                  ] : null,
                ),
                child: Text(opt,
                  style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : CropDocColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
