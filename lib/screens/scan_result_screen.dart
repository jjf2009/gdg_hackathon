import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
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

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero image
            SliverToBoxAdapter(
              child: _HeroSection(disease: disease),
            ),

            // Diagnosis content
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),

                    // Disease name + badge row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                disease.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontSize: 26,
                                    ),
                              ).animate().fadeIn(duration: 400.ms).slideX(
                                    begin: -0.05,
                                    duration: 400.ms,
                                  ),
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
                                'Found on ${disease.cropName}',
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

                    // Health badge
                    HealthBadge(severity: disease.severity)
                        .animate(
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .moveY(
                          begin: 0,
                          end: -3,
                          duration: 1800.ms,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 24),

                    // Description card
                    _InfoCard(
                      icon: Icons.info_outline_rounded,
                      text: disease.description,
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),

                    const SizedBox(height: 10),

                    // Spread info
                    _InfoCard(
                      icon: Icons.air_rounded,
                      text: disease.spreadInfo,
                      accent: CropDocColors.warning,
                    ).animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),

                    const SizedBox(height: 10),

                    // Urgency
                    _UrgencyCard(text: disease.urgency)
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.05, duration: 400.ms),

                    const SizedBox(height: 28),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: onViewTreatment,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('See What To Do'),
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

        // Floating listen button
        const Positioned(
          bottom: 24,
          right: 20,
          child: ListenFab(),
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
            blurRadius: 16,
            offset: const Offset(0, 6),
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
            Image.asset(
              disease.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: CropDocColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.eco_rounded,
                    size: 64, color: CropDocColors.primary),
              ),
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      CropDocColors.background.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Back arrow
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // Detected label
            Positioned(
              bottom: 16,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CropDocColors.danger.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pest_control_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Disease Detected',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  const _InfoCard({
    required this.icon,
    required this.text,
    this.accent,
  });

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
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CropDocColors.textPrimary,
                    height: 1.45,
                  ),
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
        border: Border.all(
          color: const Color(0xFFE9C46A).withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⏰', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B6914),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
