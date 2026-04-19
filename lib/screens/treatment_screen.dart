import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../data/treatment_database.dart';
import '../services/scan_history_service.dart';
import '../services/farm_log_service.dart';
import '../widgets/common/listen_fab.dart';
import '../widgets/treatment/step_card.dart';
import '../widgets/treatment/shop_card.dart';
import '../widgets/treatment/spray_calendar.dart';

class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FarmLogService.instance,
      builder: (context, _) {
        // Read disease from latest prediction
        final prediction = ScanHistoryService.instance.lastPrediction;

        final diseaseName = prediction?.diseaseName ?? 'Early Blight';
        final cropName = prediction?.cropName ?? 'Tomato';
        final isHealthy = prediction?.isHealthy ?? false;

        // Get disease-specific data
        final steps = TreatmentDatabase.getSteps(diseaseName);
        final shops = TreatmentDatabase.getShops(diseaseName);
        final schedule = TreatmentDatabase.getSchedule(
          diseaseName,
          cropName: cropName,
          logs: FarmLogService.instance.records,
        );

    final speechText = isHealthy
        ? 'Your $cropName plant is healthy. No treatment needed. Next check in 7 days.'
        : 'Treatment plan for $diseaseName on $cropName. ${steps.map((s) => s.instruction).join('. ')}.';

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

            // Disease reference chip — dynamic
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isHealthy ? CropDocColors.safeLight : CropDocColors.dangerLight)
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isHealthy ? CropDocColors.safe : CropDocColors.danger)
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isHealthy ? Icons.check_circle_rounded : Icons.pest_control_rounded,
                        size: 18,
                        color: isHealthy ? CropDocColors.safe : CropDocColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$diseaseName — $cropName',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isHealthy ? CropDocColors.safe : CropDocColors.danger,
                          ),
                        ),
                      ),
                      if (prediction != null)
                        Text(
                          '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isHealthy ? CropDocColors.safe : CropDocColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
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
                    Text(
                      isHealthy ? t(context, 'maintenance_tips') : t(context, 'what_to_do'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),

            // Step cards — now disease-specific
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final step = steps[i];
                    return StepCard(
                      icon: step.icon,
                      instruction: step.instruction,
                      urgencyLabel: step.urgencyLabel,
                      detail: step.detail,
                      index: i,
                    ).animate()
                        .fadeIn(delay: Duration(milliseconds: 200 + i * 120), duration: 400.ms)
                        .slideY(begin: 0.08, delay: Duration(milliseconds: 200 + i * 120), duration: 400.ms);
                  },
                  childCount: steps.length,
                ),
              ),
            ),

            // Buy nearby — only for diseased
            if (!isHealthy) ...[
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
            ],

            // Spray schedule calendar — disease-specific
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SprayCalendar(events: schedule)
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.06, duration: 400.ms),
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
      },
    );
  }
}
