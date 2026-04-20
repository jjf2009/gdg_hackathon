import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../services/scan_history_service.dart';
import '../widgets/common/health_badge.dart';
import '../widgets/common/listen_fab.dart';
import '../widgets/scan/confidence_meter.dart';
import '../widgets/scan/recovery_slider.dart';

class ScanResultScreen extends StatelessWidget {
  final VoidCallback onViewTreatment;

  const ScanResultScreen({super.key, required this.onViewTreatment});

  /// Map the disease name to a severity string for UI coloring
  String _severity(String disease) {
    final lower = disease.toLowerCase();
    if (lower == 'healthy') return 'healthy';
    if (lower.contains('blight') || lower.contains('rot') || lower.contains('virus')) {
      return 'high';
    }
    if (lower.contains('mildew') || lower.contains('spot') || lower.contains('mold')) {
      return 'medium';
    }
    return 'medium';
  }

  @override
  Widget build(BuildContext context) {
    // Read latest prediction and scan record
    final prediction = ScanHistoryService.instance.lastPrediction;
    final records = ScanHistoryService.instance.records;
    final latestRecord = records.isNotEmpty ? records.first : null;

    final cropName = prediction?.cropName ?? 'Tomato';
    final diseaseName = prediction?.diseaseName ?? 'Early Blight';
    final confidence = prediction?.confidence ?? 0.87;
    final isHealthy = prediction?.isHealthy ?? false;
    final severity = _severity(diseaseName);
    final imagePath = latestRecord?.imagePath ?? 'assets/images/early_blight_leaf.png';

    // Build display strings
    final displayDisease = diseaseName;
    final displayCrop = cropName;
    final confidencePct = (confidence * 100).toStringAsFixed(1);

    final description = isHealthy
        ? 'Your $displayCrop plant looks healthy! No disease detected. Keep maintaining good agricultural practices.'
        : '$displayDisease was detected on your $displayCrop plant with $confidencePct% confidence. '
          'This disease can spread to nearby plants if not treated promptly.';

    final spreadInfo = isHealthy
        ? 'Continue regular monitoring and preventive care for best results.'
        : 'This disease typically spreads through wind, rain splash, and contaminated tools. '
          'Inspect nearby plants and isolate affected ones.';

    final urgencyText = isHealthy
        ? 'Your plant is in good health. Schedule your next check in 7 days.'
        : 'Act within 48 hours. Apply recommended treatment and monitor for 5-7 days. '
          'Re-scan after treatment to track recovery.';

    final speechText = '$displayDisease on $displayCrop. $description $urgencyText';

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroSection(
                imagePath: imagePath,
                isHealthy: isHealthy,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayDisease,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontSize: 26),
                              ).animate().fadeIn(duration: 400.ms).slideX(
                                    begin: -0.05, duration: 400.ms),
                              const SizedBox(height: 4),
                              Text(
                                '${t(context, 'found_on')} $displayCrop',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: CropDocColors.textMuted,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${t(context, 'confidence')}: $confidencePct%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConfidenceMeter(
                          confidence: confidence,
                          severity: severity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    HealthBadge(severity: severity)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -3, duration: 1800.ms,
                            curve: Curves.easeInOut),
                    const SizedBox(height: 24),
                    _InfoCard(
                      icon: isHealthy ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                      text: description,
                      accent: isHealthy ? CropDocColors.safe : null,
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.air_rounded,
                      text: spreadInfo,
                      accent: CropDocColors.warning,
                    ).animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 10),
                    _UrgencyCard(text: urgencyText, isHealthy: isHealthy)
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 28),

                    if (!isHealthy) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: onViewTreatment,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t(context, 'see_what_to_do')),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ).animate()
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .slideY(begin: 0.1, duration: 400.ms),

                      const SizedBox(height: 12),
                    ],

                    // Share Result Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          final shareText = '🌱 CropDoc Scan Report\n'
                              '━━━━━━━━━━━━━━━\n'
                              '🌿 Crop: $displayCrop\n'
                              '🔬 Finding: $displayDisease\n'
                              '📊 Confidence: $confidencePct%\n'
                              '📅 Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n'
                              '${isHealthy ? '✅ Status: Healthy' : '⚠️ Status: Treatment Needed'}\n'
                              '━━━━━━━━━━━━━━━\n'
                              'Scanned with CropDoc - AI Crop Disease Advisor';
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Report copied to clipboard! Paste in WhatsApp or SMS.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: CropDocColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share Result'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CropDocColors.primary,
                          side: const BorderSide(color: CropDocColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ).animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms)
                        .slideY(begin: 0.1, duration: 400.ms),

                    const SizedBox(height: 20),

                    if (!isHealthy) ...[
                      // Before/After recovery slider
                      RecoverySlider(
                        beforeImage: imagePath,
                        afterImage: 'assets/images/healthy_leaf.png',
                      ).animate()
                          .fadeIn(delay: 800.ms, duration: 400.ms)
                          .slideY(begin: 0.1, duration: 400.ms),
                    ],

                    if (isHealthy) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CropDocColors.safeLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CropDocColors.safe.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.eco_rounded, color: CropDocColors.safe, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Plant is Healthy',
                              style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.w700,
                                color: CropDocColors.safe,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No treatment needed. Keep up the good work!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF2D6A4F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate()
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: ListenFab(speechText: speechText),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String imagePath;
  final bool isHealthy;
  const _HeroSection({required this.imagePath, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    final isFile = imagePath.startsWith('/');
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isFile)
              Image.file(File(imagePath), fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _fallbackImage(),
              )
            else
              Image.asset(imagePath, fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _fallbackImage(),
              ),
            Positioned(
              bottom: 0, left: 0, right: 0, height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, CropDocColors.background.withValues(alpha: 0.9)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isHealthy ? CropDocColors.safe : CropDocColors.danger).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle_rounded : Icons.pest_control_rounded,
                      color: Colors.white, size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHealthy
                          ? t(context, 'healthy')
                          : t(context, 'disease_detected'),
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() => Container(
    color: CropDocColors.primary.withValues(alpha: 0.2),
    child: const Icon(Icons.eco_rounded, size: 64, color: CropDocColors.primary),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? accent;
  const _InfoCard({required this.icon, required this.text, this.accent});

  @override
  Widget build(BuildContext context) {
    final clr = accent ?? CropDocColors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: clr, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CropDocColors.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyCard extends StatelessWidget {
  final String text;
  final bool isHealthy;
  const _UrgencyCard({required this.text, this.isHealthy = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = isHealthy ? CropDocColors.safeLight : const Color(0xFFFFF0D4);
    final borderColor = isHealthy
        ? CropDocColors.safe.withValues(alpha: 0.4)
        : const Color(0xFFE9C46A).withValues(alpha: 0.4);
    final iconColor = isHealthy ? CropDocColors.safe : const Color(0xFF8B6914);
    final textColor = isHealthy ? const Color(0xFF2D6A4F) : const Color(0xFF8B6914);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time_rounded, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
