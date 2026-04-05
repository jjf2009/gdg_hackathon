import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../data/dummy_treatments.dart';
import '../widgets/common/listen_fab.dart';
import '../widgets/treatment/step_card.dart';
import '../widgets/treatment/shop_card.dart';

class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shops = DummyTreatments.nearbyShops;
    final stepKeys = [
      (Icons.sanitizer_rounded, 'step1', 'step1_detail', 'do_today'),
      (Icons.content_cut_rounded, 'step2', 'step2_detail', 'do_today'),
      (Icons.water_drop_rounded, 'step3', 'step3_detail', 'ongoing'),
    ];

    final speechText =
        '${t(context, 'what_to_do')}. ${t(context, 'step1')}. ${t(context, 'step2')}. ${t(context, 'step3')}.';

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12, left: 20, right: 20, bottom: 4,
                  ),
                  child: Text(
                    t(context, 'treatment_plan'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),

            // Disease reference
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: CropDocColors.dangerLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CropDocColors.danger.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pest_control_rounded, size: 18, color: CropDocColors.danger),
                      const SizedBox(width: 10),
                      Text(
                        '${t(context, 'early_blight')} — ${t(context, 'tomato')}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: CropDocColors.danger),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            // What to do section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18),
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
                    Text(t(context, 'what_to_do'),
                        style: Theme.of(context).textTheme.headlineSmall),
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
                    final step = stepKeys[i];
                    return StepCard(
                      icon: step.$1,
                      instruction: t(context, step.$2),
                      urgencyLabel: t(context, step.$4),
                      detail: t(context, step.$3),
                      index: i,
                    ).animate()
                        .fadeIn(delay: Duration(milliseconds: 200 + i * 120), duration: 400.ms)
                        .slideY(begin: 0.08, delay: Duration(milliseconds: 200 + i * 120), duration: 400.ms);
                  },
                  childCount: stepKeys.length,
                ),
              ),
            ),

            // Buy nearby header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 14),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 22,
                      decoration: BoxDecoration(
                        color: CropDocColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(t(context, 'buy_nearby'),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const Spacer(),
                    const Icon(Icons.location_on_rounded, size: 16, color: CropDocColors.textMuted),
                    const SizedBox(width: 4),
                    Text('Baramati', style: Theme.of(context).textTheme.bodySmall),
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
                        .fadeIn(delay: Duration(milliseconds: 600 + i * 150), duration: 400.ms)
                        .slideY(begin: 0.06, delay: Duration(milliseconds: 600 + i * 150), duration: 400.ms);
                  },
                  childCount: shops.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        Positioned(
          bottom: 24, right: 20,
          child: ListenFab(speechText: speechText),
        ),
      ],
    );
  }
}
