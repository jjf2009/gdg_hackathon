import 'package:flutter/material.dart';
import '../models/treatment.dart';
import '../models/calendar_event.dart';

/// Disease-specific treatment database.
/// Maps model output disease names to actionable treatment plans.
class TreatmentDatabase {
  TreatmentDatabase._();

  // ─── Treatment Steps per Disease ───

  static List<TreatmentStep> getSteps(String disease) {
    final key = disease.toLowerCase().replaceAll(' ', '_');
    return _treatments[key] ?? _defaultSteps;
  }

  static List<Shop> getShops(String disease) {
    final key = disease.toLowerCase().replaceAll(' ', '_');
    final products = _products[key] ?? _products['default']!;

    // Build shops with disease-relevant products
    return [
      Shop(
        name: 'Patil Krushi Kendra',
        distanceKm: 2.3,
        address: 'Near Bus Stand, Baramati',
        phoneNumber: '9876543210',
        products: products,
      ),
      Shop(
        name: 'Sharma Agri Store',
        distanceKm: 4.1,
        address: 'Main Road, Indapur',
        phoneNumber: '9123456789',
        products: products.map((p) => Product(
          name: p.name,
          quantity: p.quantity,
          priceRupees: (p.priceRupees * 0.95).round(), // Slightly cheaper
        )).toList(),
      ),
      Shop(
        name: 'Mauli Agro Services',
        distanceKm: 6.8,
        address: 'Pune-Solapur Highway, Daund',
        phoneNumber: '9988776655',
        products: products.map((p) => Product(
          name: p.name,
          quantity: p.quantity,
          priceRupees: (p.priceRupees * 1.05).round(),
          inStock: true,
        )).toList(),
      ),
    ];
  }

  /// Generate spray/treatment calendar based on disease
  static List<CalendarEvent> getSchedule(String disease) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lower = disease.toLowerCase();
    if (lower == 'healthy') return _healthySchedule(today);
    if (lower.contains('blight')) return _blightSchedule(today, disease);
    if (lower.contains('mildew')) return _mildewSchedule(today);
    if (lower.contains('rot')) return _rotSchedule(today);
    if (lower.contains('spot')) return _spotSchedule(today);
    if (lower.contains('mold')) return _moldSchedule(today);
    if (lower.contains('virus') || lower.contains('curl')) return _virusSchedule(today);
    if (lower.contains('scab')) return _scabSchedule(today);
    return _defaultSchedule(today, disease);
  }

  // ─── Treatment Step Definitions ───

  static final Map<String, List<TreatmentStep>> _treatments = {
    'early_blight': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray Mancozeb 75% WP solution before sunset',
        urgencyLabel: 'Do today',
        detail: 'Mix 2.5g per litre of water. Spray on all leaves, top and bottom. Wear protective gloves.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove the most affected leaves immediately',
        urgencyLabel: 'Do today',
        detail: 'Cut infected leaves and take them away from the field. Do not leave on the ground — spores will spread.',
      ),
      TreatmentStep(
        icon: Icons.water_drop_rounded,
        instruction: 'Water at the base only — stop overhead irrigation',
        urgencyLabel: 'Ongoing',
        detail: 'Use drip irrigation or pour water directly at roots. Wet foliage accelerates fungal growth.',
      ),
    ],
    'late_blight': const [
      TreatmentStep(
        icon: Icons.warning_amber_rounded,
        instruction: 'Apply Metalaxyl + Mancozeb immediately',
        urgencyLabel: 'Urgent',
        detail: 'This is aggressive — mix 2g Metalaxyl-M + 2.5g Mancozeb per litre. Spray entire plant thoroughly.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove and destroy all infected plant parts',
        urgencyLabel: 'Do today',
        detail: 'Late blight spreads very fast. Burn or bag infected material. Do not compost.',
      ),
      TreatmentStep(
        icon: Icons.air,
        instruction: 'Improve air circulation between plants',
        urgencyLabel: 'This week',
        detail: 'Thin out crowded areas. Stake tomato plants upright. Better airflow slows fungal spread.',
      ),
      TreatmentStep(
        icon: Icons.repeat_rounded,
        instruction: 'Re-spray after 7 days if symptoms persist',
        urgencyLabel: 'Follow-up',
        detail: 'Continue treatment cycle until new growth appears clean. Monitor daily.',
      ),
    ],
    'powdery_mildew': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray wettable Sulphur (3g per litre)',
        urgencyLabel: 'Do today',
        detail: 'Sulphur is most effective as a preventive. Cover all leaf surfaces evenly.',
      ),
      TreatmentStep(
        icon: Icons.wb_sunny_rounded,
        instruction: 'Ensure plants get adequate sunlight',
        urgencyLabel: 'Ongoing',
        detail: 'Powdery mildew thrives in shade. Prune surrounding vegetation to increase sun exposure.',
      ),
      TreatmentStep(
        icon: Icons.water_drop_outlined,
        instruction: 'Avoid overhead watering in the evening',
        urgencyLabel: 'Ongoing',
        detail: 'Water at the base in the morning. Evening moisture on leaves creates ideal conditions for mildew.',
      ),
    ],
    'bacterial_spot': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Copper Oxychloride spray (3g/litre)',
        urgencyLabel: 'Do today',
        detail: 'Copper-based fungicides help control bacterial spread. Apply in the early morning or late evening.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove heavily spotted leaves',
        urgencyLabel: 'Do today',
        detail: 'Prune affected foliage and dispose away from the field. Disinfect pruning tools after use.',
      ),
      TreatmentStep(
        icon: Icons.recycling_rounded,
        instruction: 'Practice crop rotation next season',
        urgencyLabel: 'Plan ahead',
        detail: 'Avoid planting the same crop family in this plot for 2-3 seasons to break the disease cycle.',
      ),
    ],
    'leaf_mold': const [
      TreatmentStep(
        icon: Icons.air,
        instruction: 'Increase ventilation and reduce humidity',
        urgencyLabel: 'Do today',
        detail: 'Open greenhouse vents or thin plant spacing. Leaf mold thrives above 85% relative humidity.',
      ),
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray Chlorothalonil (2g/litre)',
        urgencyLabel: 'Do today',
        detail: 'Apply to both sides of leaves. Repeat every 10 days until symptoms improve.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove lower leaves touching the soil',
        urgencyLabel: 'This week',
        detail: 'Lower leaves are most susceptible. Removing them improves air circulation around the plant base.',
      ),
    ],
    'septoria_leaf_spot': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray Mancozeb or Chlorothalonil',
        urgencyLabel: 'Do today',
        detail: 'Mix 2.5g per litre. Apply as soon as first spots appear on lower leaves.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove infected lower leaves',
        urgencyLabel: 'Do today',
        detail: 'Septoria starts from the bottom up. Removing lower leaves slows progression significantly.',
      ),
      TreatmentStep(
        icon: Icons.grass_rounded,
        instruction: 'Add mulch around the base',
        urgencyLabel: 'This week',
        detail: 'Mulch prevents soil-borne spores from splashing onto lower leaves during rain or watering.',
      ),
    ],
    'spider_mites': const [
      TreatmentStep(
        icon: Icons.water_drop_rounded,
        instruction: 'Spray strong jet of water on leaf undersides',
        urgencyLabel: 'Do today',
        detail: 'Dislodge mites physically first. Focus on leaf undersides where colonies form.',
      ),
      TreatmentStep(
        icon: Icons.eco_rounded,
        instruction: 'Apply Neem Oil spray (5ml/litre)',
        urgencyLabel: 'Do today',
        detail: 'Neem oil disrupts mite feeding and reproduction. Spray every 5 days for 3 applications.',
      ),
      TreatmentStep(
        icon: Icons.thermostat_rounded,
        instruction: 'Increase humidity around plants',
        urgencyLabel: 'Ongoing',
        detail: 'Spider mites thrive in hot, dry conditions. Misting or mulching helps create unfavorable conditions.',
      ),
    ],
    'target_spot': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Chlorothalonil or Mancozeb',
        urgencyLabel: 'Do today',
        detail: 'Fungicide application at first sign of target-shaped spots. Cover all foliage thoroughly.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Prune affected branches and leaves',
        urgencyLabel: 'Do today',
        detail: 'Remove all leaves showing concentric ring patterns. Destroy, do not compost.',
      ),
      TreatmentStep(
        icon: Icons.water_drop_outlined,
        instruction: 'Reduce leaf wetness duration',
        urgencyLabel: 'Ongoing',
        detail: 'Water early in the day. Avoid wetting foliage. Good drainage is critical.',
      ),
    ],
    'tomato_yellow_leaf_curl_virus': const [
      TreatmentStep(
        icon: Icons.bug_report_rounded,
        instruction: 'Control whitefly vectors immediately',
        urgencyLabel: 'Urgent',
        detail: 'Use yellow sticky traps and spray Imidacloprid (0.5ml/litre). Whiteflies spread this virus.',
      ),
      TreatmentStep(
        icon: Icons.delete_forever_rounded,
        instruction: 'Remove and destroy infected plants',
        urgencyLabel: 'Do today',
        detail: 'There is no cure for viral infections. Remove infected plants to prevent spread to healthy ones.',
      ),
      TreatmentStep(
        icon: Icons.shield_rounded,
        instruction: 'Use resistant varieties next season',
        urgencyLabel: 'Plan ahead',
        detail: 'Plant TYLCV-resistant tomato varieties. Use fine-mesh insect netting over nursery seedlings.',
      ),
    ],
    'tomato_mosaic_virus': const [
      TreatmentStep(
        icon: Icons.delete_forever_rounded,
        instruction: 'Remove all infected plants immediately',
        urgencyLabel: 'Urgent',
        detail: 'Mosaic virus has no chemical cure. Uproot and destroy affected plants. Do not compost.',
      ),
      TreatmentStep(
        icon: Icons.clean_hands_rounded,
        instruction: 'Sanitize all tools and hands',
        urgencyLabel: 'Do today',
        detail: 'Mosaic virus spreads through contact. Wash hands with soap and dip tools in 10% bleach solution.',
      ),
      TreatmentStep(
        icon: Icons.block_rounded,
        instruction: 'Avoid smoking near plants',
        urgencyLabel: 'Ongoing',
        detail: 'Tobacco mosaic virus can spread from tobacco products. Wash hands before handling plants.',
      ),
    ],
    'black_rot': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Mancozeb + Copper Oxychloride',
        urgencyLabel: 'Do today',
        detail: 'Spray combination at 2g + 3g per litre. Apply at first sign of dark lesions on fruit.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove all mummified and infected fruit',
        urgencyLabel: 'Do today',
        detail: 'Rotting fruit is a major source of reinfection. Remove and destroy all affected fruit.',
      ),
      TreatmentStep(
        icon: Icons.recycling_rounded,
        instruction: 'Improve drainage and air circulation',
        urgencyLabel: 'This week',
        detail: 'Prune for open canopy. Ensure good water drainage to prevent standing moisture.',
      ),
    ],
    'apple_scab': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray Mancozeb during wet weather',
        urgencyLabel: 'Do today',
        detail: 'Apply before rain events when possible. Scab spores are released during wet periods.',
      ),
      TreatmentStep(
        icon: Icons.yard_rounded,
        instruction: 'Rake and destroy fallen leaves',
        urgencyLabel: 'This week',
        detail: 'Fallen leaves harbor scab spores over winter. Remove and burn or bag them.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Prune for better air circulation',
        urgencyLabel: 'This week',
        detail: 'Open up the canopy to allow leaves to dry faster after rain.',
      ),
    ],
    'cedar_apple_rust': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Myclobutanil fungicide',
        urgencyLabel: 'Do today',
        detail: 'Spray at pink bud stage and again after petal fall. This is the most effective timing.',
      ),
      TreatmentStep(
        icon: Icons.park_rounded,
        instruction: 'Remove nearby cedar/juniper trees if possible',
        urgencyLabel: 'Long-term',
        detail: 'Rust alternates between apple and cedar hosts. Removing one breaks the cycle.',
      ),
    ],
    'leaf_scorch': const [
      TreatmentStep(
        icon: Icons.water_drop_rounded,
        instruction: 'Ensure consistent deep watering',
        urgencyLabel: 'Do today',
        detail: 'Leaf scorch is often caused by drought stress. Water deeply 2-3 times per week.',
      ),
      TreatmentStep(
        icon: Icons.grass_rounded,
        instruction: 'Apply organic mulch around the base',
        urgencyLabel: 'This week',
        detail: 'Mulch retains moisture and keeps roots cool. Apply 2-3 inches around the plant, not touching the stem.',
      ),
    ],
    'haunglongbing': const [
      TreatmentStep(
        icon: Icons.bug_report_rounded,
        instruction: 'Control Asian Citrus Psyllid vectors',
        urgencyLabel: 'Urgent',
        detail: 'Apply systemic insecticide (Imidacloprid). Use yellow sticky traps for monitoring.',
      ),
      TreatmentStep(
        icon: Icons.eco_rounded,
        instruction: 'Apply foliar nutrition (zinc, manganese)',
        urgencyLabel: 'This week',
        detail: 'Micronutrient sprays help infected trees maintain some productivity. Not a cure.',
      ),
      TreatmentStep(
        icon: Icons.delete_forever_rounded,
        instruction: 'Remove severely infected trees',
        urgencyLabel: 'Plan ahead',
        detail: 'HLB has no cure. Heavily affected trees should be removed to protect healthy ones nearby.',
      ),
    ],
    'common_rust': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Propiconazole fungicide',
        urgencyLabel: 'Do today',
        detail: 'Spray at first sign of pustules. Most effective when applied early in the infection.',
      ),
      TreatmentStep(
        icon: Icons.shield_rounded,
        instruction: 'Plant rust-resistant varieties next season',
        urgencyLabel: 'Plan ahead',
        detail: 'Genetic resistance is the most effective control. Check with local seed suppliers.',
      ),
    ],
    'northern_leaf_blight': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Propiconazole or Azoxystrobin',
        urgencyLabel: 'Do today',
        detail: 'Spray when lesions first appear on lower leaves. Protect upper canopy.',
      ),
      TreatmentStep(
        icon: Icons.recycling_rounded,
        instruction: 'Practice crop rotation',
        urgencyLabel: 'Plan ahead',
        detail: 'Avoid planting corn in the same field for 2 consecutive seasons. Rotate with soybeans or legumes.',
      ),
    ],
    'cercospora_leaf_spot': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Mancozeb or Azoxystrobin',
        urgencyLabel: 'Do today',
        detail: 'Spray at first sign of gray spots with dark borders. Cover all leaf surfaces.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove infected lower leaves',
        urgencyLabel: 'Do today',
        detail: 'Gray leaf spot progresses from bottom up. Early removal slows spread.',
      ),
      TreatmentStep(
        icon: Icons.recycling_rounded,
        instruction: 'Incorporate crop residue after harvest',
        urgencyLabel: 'Post-harvest',
        detail: 'Tillage buries infected debris, reducing spore carry-over to next season.',
      ),
    ],
    'leaf_blight': const [
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Spray Bordeaux mixture (1%)',
        urgencyLabel: 'Do today',
        detail: 'Bordeaux mixture (copper sulphate + lime) is effective for leaf blights on grapes.',
      ),
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Remove and destroy affected leaves',
        urgencyLabel: 'Do today',
        detail: 'Prune infected parts. Improve canopy ventilation by training vines properly.',
      ),
    ],
    'esca': const [
      TreatmentStep(
        icon: Icons.content_cut_rounded,
        instruction: 'Prune out dead wood and cankers',
        urgencyLabel: 'Do today',
        detail: 'Remove all dead/discolored wood. Make clean cuts and seal with wound paste.',
      ),
      TreatmentStep(
        icon: Icons.sanitizer_rounded,
        instruction: 'Apply Trichoderma biological agent',
        urgencyLabel: 'This week',
        detail: 'Apply Trichoderma to pruning wounds to prevent reinfection. Biological control is preferred.',
      ),
    ],
  };

  static const List<TreatmentStep> _defaultSteps = [
    TreatmentStep(
      icon: Icons.sanitizer_rounded,
      instruction: 'Apply appropriate fungicide based on disease type',
      urgencyLabel: 'Do today',
      detail: 'Consult your local agricultural officer for the specific fungicide recommendation for this disease.',
    ),
    TreatmentStep(
      icon: Icons.content_cut_rounded,
      instruction: 'Remove all visibly affected plant parts',
      urgencyLabel: 'Do today',
      detail: 'Cut and remove infected leaves, stems, or fruit. Destroy them — do not leave on the field.',
    ),
    TreatmentStep(
      icon: Icons.water_drop_rounded,
      instruction: 'Adjust watering and improve drainage',
      urgencyLabel: 'Ongoing',
      detail: 'Avoid overhead watering. Ensure good field drainage to reduce favorable conditions for disease.',
    ),
  ];

  // ─── Product Recommendations per Disease ───

  static final Map<String, List<Product>> _products = {
    'early_blight': const [
      Product(name: 'Mancozeb 75% WP', quantity: '500g', priceRupees: 180),
      Product(name: 'Chlorothalonil', quantity: '250ml', priceRupees: 320),
    ],
    'late_blight': const [
      Product(name: 'Metalaxyl-M 4% + Mancozeb 64% WP', quantity: '500g', priceRupees: 420),
      Product(name: 'Copper Oxychloride 50% WP', quantity: '500g', priceRupees: 240),
    ],
    'powdery_mildew': const [
      Product(name: 'Wettable Sulphur 80% WP', quantity: '500g', priceRupees: 150),
      Product(name: 'Karathane (Dinocap)', quantity: '250ml', priceRupees: 350),
    ],
    'spider_mites': const [
      Product(name: 'Neem Oil (organic)', quantity: '500ml', priceRupees: 220),
      Product(name: 'Abamectin 1.9% EC', quantity: '100ml', priceRupees: 280),
    ],
    'bacterial_spot': const [
      Product(name: 'Copper Oxychloride 50% WP', quantity: '500g', priceRupees: 240),
      Product(name: 'Streptomycin Sulphate', quantity: '100g', priceRupees: 350),
    ],
    'black_rot': const [
      Product(name: 'Mancozeb 75% WP', quantity: '500g', priceRupees: 180),
      Product(name: 'Copper Oxychloride 50% WP', quantity: '500g', priceRupees: 240),
    ],
    'default': const [
      Product(name: 'Mancozeb 75% WP', quantity: '500g', priceRupees: 180),
      Product(name: 'Neem Oil (organic)', quantity: '500ml', priceRupees: 220),
    ],
  };

  // ─── Schedule Generators ───

  static List<CalendarEvent> _blightSchedule(DateTime today, String disease) {
    final sprayName = disease.toLowerCase().contains('late')
        ? 'Metalaxyl + Mancozeb spray'
        : 'Mancozeb evening spray';
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: sprayName, isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 1)), actionKey: 'rest'),
      CalendarEvent(date: today.add(const Duration(days: 2)), actionKey: 'rest'),
      CalendarEvent(date: today.add(const Duration(days: 3)), actionKey: 'recheck', note: 'Check treated leaves'),
      CalendarEvent(date: today.add(const Duration(days: 5)), actionKey: 'spray', note: 'Follow-up $sprayName'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'recheck', note: 'Assess treatment progress'),
      CalendarEvent(date: today.add(const Duration(days: 10)), actionKey: 'spray', note: 'Final preventive spray'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Final disease check'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'harvest', note: 'Safe harvest window opens'),
    ];
  }

  static List<CalendarEvent> _mildewSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Sulphur spray (morning)', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 3)), actionKey: 'recheck', note: 'Check mildew spread'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Follow-up Sulphur spray'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Assess recovery'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'harvest', note: 'Safe harvest window'),
    ];
  }

  static List<CalendarEvent> _rotSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Mancozeb + Copper spray', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 2)), actionKey: 'recheck', note: 'Remove any new rot'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Second spray application'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Final inspection'),
    ];
  }

  static List<CalendarEvent> _spotSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Chlorothalonil spray', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 3)), actionKey: 'recheck', note: 'Check for new spots'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Follow-up spray'),
      CalendarEvent(date: today.add(const Duration(days: 10)), actionKey: 'recheck', note: 'Assess treatment'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'harvest', note: 'Harvest window'),
    ];
  }

  static List<CalendarEvent> _moldSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Chlorothalonil spray', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 1)), actionKey: 'recheck', note: 'Check ventilation improved'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Second spray if needed'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Final check'),
    ];
  }

  static List<CalendarEvent> _virusSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Insecticide for vector control', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 1)), actionKey: 'recheck', note: 'Remove infected plants'),
      CalendarEvent(date: today.add(const Duration(days: 3)), actionKey: 'recheck', note: 'Check for new infections'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Follow-up insecticide'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Monitor healthy plants'),
    ];
  }

  static List<CalendarEvent> _scabSchedule(DateTime today) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Mancozeb spray', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 5)), actionKey: 'recheck', note: 'Check leaf condition'),
      CalendarEvent(date: today.add(const Duration(days: 10)), actionKey: 'spray', note: 'Preventive spray'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'harvest', note: 'Harvest assessment'),
    ];
  }

  static List<CalendarEvent> _healthySchedule(DateTime today) {
    return [
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'recheck', note: 'Routine health check'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'spray', note: 'Preventive Neem Oil spray'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'recheck', note: 'Pre-harvest inspection'),
      CalendarEvent(date: today.add(const Duration(days: 28)), actionKey: 'harvest', note: 'Expected harvest window'),
    ];
  }

  static List<CalendarEvent> _defaultSchedule(DateTime today, String disease) {
    return [
      CalendarEvent(date: today, actionKey: 'spray', note: 'Apply recommended treatment', isUrgent: true),
      CalendarEvent(date: today.add(const Duration(days: 3)), actionKey: 'recheck', note: 'Check treatment effect'),
      CalendarEvent(date: today.add(const Duration(days: 7)), actionKey: 'spray', note: 'Follow-up spray'),
      CalendarEvent(date: today.add(const Duration(days: 14)), actionKey: 'recheck', note: 'Final disease check'),
      CalendarEvent(date: today.add(const Duration(days: 21)), actionKey: 'harvest', note: 'Safe harvest window'),
    ];
  }
}
