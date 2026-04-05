import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../data/dummy_diseases.dart';
import '../models/disease.dart';
import '../widgets/common/health_badge.dart';
import '../widgets/common/listen_fab.dart';
import '../widgets/scan/confidence_meter.dart';

class ScanResultScreen extends StatelessWidget {
  final VoidCallback onViewTreatment;

  const ScanResultScreen({super.key, required this.onViewTreatment});

  @override
  Widget build(BuildContext context) {
    final disease = DummyDiseases.earlyBlight;
    final diseaseName = t(context, 'early_blight');
    final speechText =
        '${t(context, 'early_blight')}. ${t(context, 'early_blight_desc')} ${t(context, 'early_blight_urgency')}';

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroSection(disease: disease),
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
                                diseaseName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontSize: 26),
                              ).animate().fadeIn(duration: 400.ms).slideX(
                                    begin: -0.05, duration: 400.ms),
                              const SizedBox(height: 4),
                              Text(
                                disease.scientificName,
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
                                '${t(context, 'found_on')} ${t(context, 'tomato')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ConfidenceMeter(
                          confidence: disease.confidence,
                          severity: disease.severity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    HealthBadge(severity: disease.severity)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -3, duration: 1800.ms,
                            curve: Curves.easeInOut),
                    const SizedBox(height: 24),
                    _InfoCard(
                      icon: Icons.info_outline_rounded,
                      text: t(context, 'early_blight_desc'),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.air_rounded,
                      text: t(context, 'early_blight_spread'),
                      accent: CropDocColors.warning,
                    ).animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 10),
                    _UrgencyCard(text: t(context, 'early_blight_urgency'))
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),
                    const SizedBox(height: 28),
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
  final Disease disease;
  const _HeroSection({required this.disease});

  @override
  Widget build(BuildContext context) {
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
            Image.asset(disease.imagePath, fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: CropDocColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.eco_rounded, size: 64, color: CropDocColors.primary),
              ),
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
                  color: CropDocColors.danger.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pest_control_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      t(context, 'disease_detected'),
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
  const _UrgencyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF8B6914)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B6914), fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
