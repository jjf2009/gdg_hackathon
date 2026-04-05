import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../data/dummy_treatments.dart';
import '../widgets/common/listen_fab.dart';
import '../widgets/treatment/step_card.dart';
import '../widgets/treatment/shop_card.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  bool _isMarathi = false;

  @override
  Widget build(BuildContext context) {
    final steps = DummyTreatments.earlyBlightSteps;
    final shops = DummyTreatments.nearbyShops;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App bar area
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12, left: 20, right: 20, bottom: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Treatment Plan',
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      // Language toggle
                      _LanguageToggle(
                        isMarathi: _isMarathi,
                        onChanged: (v) => setState(() => _isMarathi = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Disease reference
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CropDocColors.dangerLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CropDocColors.danger.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pest_control_rounded,
                          size: 18, color: CropDocColors.danger),
                      const SizedBox(width: 10),
                      Text(
                        _isMarathi
                            ? 'लवकर करपा — टोमॅटो'
                            : 'Early Blight — Tomato',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: CropDocColors.danger,
                                ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            // What to do section
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 20, right: 20, top: 18),
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
                      _isMarathi ? 'आत्ता काय करावे' : 'What to do now',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),

            // Step cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final step = steps[i];
                    return StepCard(
                      emoji: step.icon,
                      instruction: step.instruction,
                      urgencyLabel: step.urgencyLabel,
                      detail: step.detail,
                      index: i,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 200 + i * 120),
                          duration: 400.ms,
                        )
                        .slideY(
                          begin: 0.08,
                          delay: Duration(milliseconds: 200 + i * 120),
                          duration: 400.ms,
                        );
                  },
                  childCount: steps.length,
                ),
              ),
            ),

            // Buy nearby section header
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 20, right: 20, top: 14),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: CropDocColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isMarathi ? 'जवळपास खरेदी करा' : 'Buy nearby',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    Icon(Icons.location_on_rounded,
                        size: 16, color: CropDocColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Baramati',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // Shop cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    return ShopCard(shop: shops[i])
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 600 + i * 150),
                          duration: 400.ms,
                        )
                        .slideY(
                          begin: 0.06,
                          delay: Duration(milliseconds: 600 + i * 150),
                          duration: 400.ms,
                        );
                  },
                  childCount: shops.length,
                ),
              ),
            ),

            // Bottom spacer
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
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

class _LanguageToggle extends StatelessWidget {
  final bool isMarathi;
  final ValueChanged<bool> onChanged;

  const _LanguageToggle({
    required this.isMarathi,
    required this.onChanged,
  });

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
        children: [
          _TogglePill(
            label: 'EN',
            isActive: !isMarathi,
            onTap: () => onChanged(false),
          ),
          _TogglePill(
            label: 'मरा',
            isActive: isMarathi,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? CropDocColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : CropDocColors.textMuted,
          ),
        ),
      ),
    );
  }
}
