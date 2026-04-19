/**
 * CropDoc Database Seeder
 *
 * Seeds the Supabase database with all the disease, treatment, product,
 * shop, scan history, and community alert data from the Flutter app.
 *
 * Usage: npm run seed (or: node seed/seed.js)
 */

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const supabase = require('../config/supabase');

// ─── Seed Data ─────────────────────────────────────────────────

const diseases = [
  {
    name: 'Early Blight',
    scientific_name: 'Alternaria solani',
    severity: 'high',
    description:
      'This fungus makes round brown spots with rings on the leaves. It starts on the older leaves at the bottom and spreads upward.',
    spread_info:
      'Spreads fast in humid weather, especially when leaves stay wet overnight.',
    urgency: 'Act within 24 hours — this spreads quickly in wet conditions.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Late Blight',
    scientific_name: 'Phytophthora infestans',
    severity: 'critical',
    description:
      'Dark, water-soaked patches on leaves and stems. White fuzzy growth may appear underneath in humid mornings.',
    spread_info: 'Can destroy an entire field in days during rainy season.',
    urgency: 'Emergency — spray today before sunset.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Powdery Mildew',
    scientific_name: 'Erysiphe cichoracearum',
    severity: 'medium',
    description:
      'White powdery coating on the top of leaves. Leaves may curl and turn yellow over time.',
    spread_info: 'Common in warm, dry days followed by cool, humid nights.',
    urgency: 'Treat within 2-3 days to prevent spread.',
    crop_name: 'Onion',
    image_url: 'assets/images/healthy_leaf.png',
  },
  {
    name: 'Healthy',
    scientific_name: '-',
    severity: 'low',
    description: 'This leaf looks healthy! No signs of disease spotted.',
    spread_info: '',
    urgency: 'No action needed. Keep monitoring weekly.',
    crop_name: 'Tomato',
    image_url: 'assets/images/healthy_leaf.png',
  },
  {
    name: 'Bacterial Spot',
    scientific_name: 'Xanthomonas campestris',
    severity: 'medium',
    description:
      'Small, water-soaked spots on leaves that turn brown with yellow halos. Can affect fruit too.',
    spread_info: 'Spreads through rain splash and contaminated tools.',
    urgency: 'Apply copper spray within 48 hours.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Leaf Mold',
    scientific_name: 'Passalora fulva',
    severity: 'medium',
    description:
      'Yellow patches on upper leaf surfaces with olive-green to gray fuzzy growth underneath.',
    spread_info: 'Thrives in high humidity environments above 85%.',
    urgency: 'Improve ventilation and apply fungicide within 2 days.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Septoria Leaf Spot',
    scientific_name: 'Septoria lycopersici',
    severity: 'medium',
    description:
      'Small circular spots with dark brown borders and tan centers. Starts on lower leaves.',
    spread_info: 'Spreads from bottom up. Rain splash carries spores.',
    urgency: 'Remove affected leaves and spray fungicide within 48 hours.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Spider Mites',
    scientific_name: 'Tetranychus urticae',
    severity: 'medium',
    description:
      'Tiny yellow or white speckling on leaves. Fine webbing visible on undersides of leaves.',
    spread_info: 'Thrives in hot, dry conditions. Spreads by wind.',
    urgency: 'Act within 2-3 days. Population can double in a week.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Target Spot',
    scientific_name: 'Corynespora cassiicola',
    severity: 'medium',
    description:
      'Concentric ring patterns (target-like) on leaves, stems, and fruit.',
    spread_info: 'Warm, wet conditions accelerate spread.',
    urgency: 'Apply fungicide at first sign of ring patterns.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Yellow Leaf Curl Virus',
    scientific_name: 'Begomovirus',
    severity: 'critical',
    description:
      'Leaves curl upward and turn yellow. Stunted growth. Spread by whiteflies.',
    spread_info: 'Transmitted by whitefly vectors. No plant-to-plant contact spread.',
    urgency: 'Urgent — control whiteflies immediately. Remove infected plants.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Mosaic Virus',
    scientific_name: 'Tobamovirus',
    severity: 'critical',
    description:
      'Mottled light and dark green pattern on leaves. Leaves may be distorted or reduced in size.',
    spread_info: 'Spreads through contact, contaminated tools, and tobacco products.',
    urgency: 'Remove infected plants immediately. Sanitize all tools.',
    crop_name: 'Tomato',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Black Rot',
    scientific_name: 'Guignardia bidwellii',
    severity: 'high',
    description:
      'Dark, expanding lesions on fruit that shrivel and mummify. Brown spots on leaves.',
    spread_info: 'Mummified fruit is the main source of reinfection.',
    urgency: 'Remove all infected fruit immediately. Apply fungicide.',
    crop_name: 'Grape',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Apple Scab',
    scientific_name: 'Venturia inaequalis',
    severity: 'medium',
    description:
      'Olive-green to brown velvety spots on leaves and fruit. Fruit may crack.',
    spread_info: 'Spores released during wet periods from fallen leaves.',
    urgency: 'Spray fungicide before rain events.',
    crop_name: 'Apple',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Cedar Apple Rust',
    scientific_name: 'Gymnosporangium juniperi-virginianae',
    severity: 'medium',
    description:
      'Bright orange-yellow spots on upper leaf surfaces. Tube-like projections underneath.',
    spread_info: 'Alternates between apple and cedar/juniper hosts.',
    urgency: 'Apply fungicide at pink bud stage.',
    crop_name: 'Apple',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Common Rust',
    scientific_name: 'Puccinia sorghi',
    severity: 'medium',
    description:
      'Small, circular to elongated brown pustules on both leaf surfaces.',
    spread_info: 'Wind-borne spores can travel long distances.',
    urgency: 'Apply fungicide at first sign of pustules.',
    crop_name: 'Corn',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Northern Leaf Blight',
    scientific_name: 'Exserohilum turcicum',
    severity: 'high',
    description:
      'Long, cigar-shaped grayish-green lesions on leaves. Can cause significant yield loss.',
    spread_info: 'Favored by cool, wet weather. Debris-borne inoculum.',
    urgency: 'Spray fungicide when lesions appear on lower leaves.',
    crop_name: 'Corn',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Cercospora Leaf Spot',
    scientific_name: 'Cercospora zeae-maydis',
    severity: 'medium',
    description:
      'Rectangular gray spots between leaf veins. Spots may have dark borders.',
    spread_info: 'Progresses from bottom up. Favored by warm, humid weather.',
    urgency: 'Apply fungicide when spots first appear on lower leaves.',
    crop_name: 'Corn',
    image_url: 'assets/images/early_blight_leaf.png',
  },
  {
    name: 'Bacterial Blight',
    scientific_name: 'Xanthomonas axonopodis',
    severity: 'high',
    description:
      'Water-soaked lesions on leaves that turn brown and papery. Angular spots between veins.',
    spread_info: 'Spreads during monsoon rains and through infected seed.',
    urgency: 'Apply copper-based bactericide within 24 hours.',
    crop_name: 'Cotton',
    image_url: 'assets/images/early_blight_leaf.png',
  },
];

const treatments = [
  // Early Blight
  { disease_key: 'early_blight', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Spray Mancozeb 75% WP solution before sunset', urgency_label: 'Do today', detail: 'Mix 2.5g per litre of water. Spray on all leaves, top and bottom. Wear protective gloves.' },
  { disease_key: 'early_blight', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove the most affected leaves immediately', urgency_label: 'Do today', detail: 'Cut infected leaves and take them away from the field. Do not leave on the ground — spores will spread.' },
  { disease_key: 'early_blight', step_order: 3, icon_name: 'water_drop_rounded', instruction: 'Water at the base only — stop overhead irrigation', urgency_label: 'Ongoing', detail: 'Use drip irrigation or pour water directly at roots. Wet foliage accelerates fungal growth.' },

  // Late Blight
  { disease_key: 'late_blight', step_order: 1, icon_name: 'warning_amber_rounded', instruction: 'Apply Metalaxyl + Mancozeb immediately', urgency_label: 'Urgent', detail: 'This is aggressive — mix 2g Metalaxyl-M + 2.5g Mancozeb per litre. Spray entire plant thoroughly.' },
  { disease_key: 'late_blight', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove and destroy all infected plant parts', urgency_label: 'Do today', detail: 'Late blight spreads very fast. Burn or bag infected material. Do not compost.' },
  { disease_key: 'late_blight', step_order: 3, icon_name: 'air', instruction: 'Improve air circulation between plants', urgency_label: 'This week', detail: 'Thin out crowded areas. Stake tomato plants upright. Better airflow slows fungal spread.' },
  { disease_key: 'late_blight', step_order: 4, icon_name: 'repeat_rounded', instruction: 'Re-spray after 7 days if symptoms persist', urgency_label: 'Follow-up', detail: 'Continue treatment cycle until new growth appears clean. Monitor daily.' },

  // Powdery Mildew
  { disease_key: 'powdery_mildew', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Spray wettable Sulphur (3g per litre)', urgency_label: 'Do today', detail: 'Sulphur is most effective as a preventive. Cover all leaf surfaces evenly.' },
  { disease_key: 'powdery_mildew', step_order: 2, icon_name: 'wb_sunny_rounded', instruction: 'Ensure plants get adequate sunlight', urgency_label: 'Ongoing', detail: 'Powdery mildew thrives in shade. Prune surrounding vegetation to increase sun exposure.' },
  { disease_key: 'powdery_mildew', step_order: 3, icon_name: 'water_drop_outlined', instruction: 'Avoid overhead watering in the evening', urgency_label: 'Ongoing', detail: 'Water at the base in the morning. Evening moisture on leaves creates ideal conditions for mildew.' },

  // Bacterial Spot
  { disease_key: 'bacterial_spot', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Copper Oxychloride spray (3g/litre)', urgency_label: 'Do today', detail: 'Copper-based fungicides help control bacterial spread. Apply in the early morning or late evening.' },
  { disease_key: 'bacterial_spot', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove heavily spotted leaves', urgency_label: 'Do today', detail: 'Prune affected foliage and dispose away from the field. Disinfect pruning tools after use.' },
  { disease_key: 'bacterial_spot', step_order: 3, icon_name: 'recycling_rounded', instruction: 'Practice crop rotation next season', urgency_label: 'Plan ahead', detail: 'Avoid planting the same crop family in this plot for 2-3 seasons to break the disease cycle.' },

  // Leaf Mold
  { disease_key: 'leaf_mold', step_order: 1, icon_name: 'air', instruction: 'Increase ventilation and reduce humidity', urgency_label: 'Do today', detail: 'Open greenhouse vents or thin plant spacing. Leaf mold thrives above 85% relative humidity.' },
  { disease_key: 'leaf_mold', step_order: 2, icon_name: 'sanitizer_rounded', instruction: 'Spray Chlorothalonil (2g/litre)', urgency_label: 'Do today', detail: 'Apply to both sides of leaves. Repeat every 10 days until symptoms improve.' },
  { disease_key: 'leaf_mold', step_order: 3, icon_name: 'content_cut_rounded', instruction: 'Remove lower leaves touching the soil', urgency_label: 'This week', detail: 'Lower leaves are most susceptible. Removing them improves air circulation around the plant base.' },

  // Septoria Leaf Spot
  { disease_key: 'septoria_leaf_spot', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Spray Mancozeb or Chlorothalonil', urgency_label: 'Do today', detail: 'Mix 2.5g per litre. Apply as soon as first spots appear on lower leaves.' },
  { disease_key: 'septoria_leaf_spot', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove infected lower leaves', urgency_label: 'Do today', detail: 'Septoria starts from the bottom up. Removing lower leaves slows progression significantly.' },
  { disease_key: 'septoria_leaf_spot', step_order: 3, icon_name: 'grass_rounded', instruction: 'Add mulch around the base', urgency_label: 'This week', detail: 'Mulch prevents soil-borne spores from splashing onto lower leaves during rain or watering.' },

  // Spider Mites
  { disease_key: 'spider_mites', step_order: 1, icon_name: 'water_drop_rounded', instruction: 'Spray strong jet of water on leaf undersides', urgency_label: 'Do today', detail: 'Dislodge mites physically first. Focus on leaf undersides where colonies form.' },
  { disease_key: 'spider_mites', step_order: 2, icon_name: 'eco_rounded', instruction: 'Apply Neem Oil spray (5ml/litre)', urgency_label: 'Do today', detail: 'Neem oil disrupts mite feeding and reproduction. Spray every 5 days for 3 applications.' },
  { disease_key: 'spider_mites', step_order: 3, icon_name: 'thermostat_rounded', instruction: 'Increase humidity around plants', urgency_label: 'Ongoing', detail: 'Spider mites thrive in hot, dry conditions. Misting or mulching helps create unfavorable conditions.' },

  // Target Spot
  { disease_key: 'target_spot', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Chlorothalonil or Mancozeb', urgency_label: 'Do today', detail: 'Fungicide application at first sign of target-shaped spots. Cover all foliage thoroughly.' },
  { disease_key: 'target_spot', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Prune affected branches and leaves', urgency_label: 'Do today', detail: 'Remove all leaves showing concentric ring patterns. Destroy, do not compost.' },
  { disease_key: 'target_spot', step_order: 3, icon_name: 'water_drop_outlined', instruction: 'Reduce leaf wetness duration', urgency_label: 'Ongoing', detail: 'Water early in the day. Avoid wetting foliage. Good drainage is critical.' },

  // Yellow Leaf Curl Virus
  { disease_key: 'tomato_yellow_leaf_curl_virus', step_order: 1, icon_name: 'bug_report_rounded', instruction: 'Control whitefly vectors immediately', urgency_label: 'Urgent', detail: 'Use yellow sticky traps and spray Imidacloprid (0.5ml/litre). Whiteflies spread this virus.' },
  { disease_key: 'tomato_yellow_leaf_curl_virus', step_order: 2, icon_name: 'delete_forever_rounded', instruction: 'Remove and destroy infected plants', urgency_label: 'Do today', detail: 'There is no cure for viral infections. Remove infected plants to prevent spread to healthy ones.' },
  { disease_key: 'tomato_yellow_leaf_curl_virus', step_order: 3, icon_name: 'shield_rounded', instruction: 'Use resistant varieties next season', urgency_label: 'Plan ahead', detail: 'Plant TYLCV-resistant tomato varieties. Use fine-mesh insect netting over nursery seedlings.' },

  // Mosaic Virus
  { disease_key: 'tomato_mosaic_virus', step_order: 1, icon_name: 'delete_forever_rounded', instruction: 'Remove all infected plants immediately', urgency_label: 'Urgent', detail: 'Mosaic virus has no chemical cure. Uproot and destroy affected plants. Do not compost.' },
  { disease_key: 'tomato_mosaic_virus', step_order: 2, icon_name: 'clean_hands_rounded', instruction: 'Sanitize all tools and hands', urgency_label: 'Do today', detail: 'Mosaic virus spreads through contact. Wash hands with soap and dip tools in 10% bleach solution.' },
  { disease_key: 'tomato_mosaic_virus', step_order: 3, icon_name: 'block_rounded', instruction: 'Avoid smoking near plants', urgency_label: 'Ongoing', detail: 'Tobacco mosaic virus can spread from tobacco products. Wash hands before handling plants.' },

  // Black Rot
  { disease_key: 'black_rot', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Mancozeb + Copper Oxychloride', urgency_label: 'Do today', detail: 'Spray combination at 2g + 3g per litre. Apply at first sign of dark lesions on fruit.' },
  { disease_key: 'black_rot', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove all mummified and infected fruit', urgency_label: 'Do today', detail: 'Rotting fruit is a major source of reinfection. Remove and destroy all affected fruit.' },
  { disease_key: 'black_rot', step_order: 3, icon_name: 'recycling_rounded', instruction: 'Improve drainage and air circulation', urgency_label: 'This week', detail: 'Prune for open canopy. Ensure good water drainage to prevent standing moisture.' },

  // Apple Scab
  { disease_key: 'apple_scab', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Spray Mancozeb during wet weather', urgency_label: 'Do today', detail: 'Apply before rain events when possible. Scab spores are released during wet periods.' },
  { disease_key: 'apple_scab', step_order: 2, icon_name: 'yard_rounded', instruction: 'Rake and destroy fallen leaves', urgency_label: 'This week', detail: 'Fallen leaves harbor scab spores over winter. Remove and burn or bag them.' },
  { disease_key: 'apple_scab', step_order: 3, icon_name: 'content_cut_rounded', instruction: 'Prune for better air circulation', urgency_label: 'This week', detail: 'Open up the canopy to allow leaves to dry faster after rain.' },

  // Cedar Apple Rust
  { disease_key: 'cedar_apple_rust', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Myclobutanil fungicide', urgency_label: 'Do today', detail: 'Spray at pink bud stage and again after petal fall. This is the most effective timing.' },
  { disease_key: 'cedar_apple_rust', step_order: 2, icon_name: 'park_rounded', instruction: 'Remove nearby cedar/juniper trees if possible', urgency_label: 'Long-term', detail: 'Rust alternates between apple and cedar hosts. Removing one breaks the cycle.' },

  // Common Rust
  { disease_key: 'common_rust', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Propiconazole fungicide', urgency_label: 'Do today', detail: 'Spray at first sign of pustules. Most effective when applied early in the infection.' },
  { disease_key: 'common_rust', step_order: 2, icon_name: 'shield_rounded', instruction: 'Plant rust-resistant varieties next season', urgency_label: 'Plan ahead', detail: 'Genetic resistance is the most effective control. Check with local seed suppliers.' },

  // Northern Leaf Blight
  { disease_key: 'northern_leaf_blight', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Propiconazole or Azoxystrobin', urgency_label: 'Do today', detail: 'Spray when lesions first appear on lower leaves. Protect upper canopy.' },
  { disease_key: 'northern_leaf_blight', step_order: 2, icon_name: 'recycling_rounded', instruction: 'Practice crop rotation', urgency_label: 'Plan ahead', detail: 'Avoid planting corn in the same field for 2 consecutive seasons. Rotate with soybeans or legumes.' },

  // Cercospora Leaf Spot
  { disease_key: 'cercospora_leaf_spot', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Mancozeb or Azoxystrobin', urgency_label: 'Do today', detail: 'Spray at first sign of gray spots with dark borders. Cover all leaf surfaces.' },
  { disease_key: 'cercospora_leaf_spot', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove infected lower leaves', urgency_label: 'Do today', detail: 'Gray leaf spot progresses from bottom up. Early removal slows spread.' },
  { disease_key: 'cercospora_leaf_spot', step_order: 3, icon_name: 'recycling_rounded', instruction: 'Incorporate crop residue after harvest', urgency_label: 'Post-harvest', detail: 'Tillage buries infected debris, reducing spore carry-over to next season.' },

  // Bacterial Blight (Cotton/Soybean)
  { disease_key: 'bacterial_blight', step_order: 1, icon_name: 'sanitizer_rounded', instruction: 'Apply Copper Oxychloride spray', urgency_label: 'Urgent', detail: 'Spray 3g per litre on all affected plants. Repeat after 7 days if rain occurs.' },
  { disease_key: 'bacterial_blight', step_order: 2, icon_name: 'content_cut_rounded', instruction: 'Remove severely affected leaves and branches', urgency_label: 'Do today', detail: 'Destroy infected material. Do not leave debris in the field.' },
  { disease_key: 'bacterial_blight', step_order: 3, icon_name: 'shield_rounded', instruction: 'Use certified disease-free seed next season', urgency_label: 'Plan ahead', detail: 'Infected seed is the primary source of bacterial blight. Use treated, certified seed.' },
];

const products = [
  // Early Blight
  { disease_key: 'early_blight', name: 'Mancozeb 75% WP', quantity: '500g', price_rupees: 180, in_stock: true },
  { disease_key: 'early_blight', name: 'Chlorothalonil', quantity: '250ml', price_rupees: 320, in_stock: true },

  // Late Blight
  { disease_key: 'late_blight', name: 'Metalaxyl-M 4% + Mancozeb 64% WP', quantity: '500g', price_rupees: 420, in_stock: true },
  { disease_key: 'late_blight', name: 'Copper Oxychloride 50% WP', quantity: '500g', price_rupees: 240, in_stock: true },

  // Powdery Mildew
  { disease_key: 'powdery_mildew', name: 'Wettable Sulphur 80% WP', quantity: '500g', price_rupees: 150, in_stock: true },
  { disease_key: 'powdery_mildew', name: 'Karathane (Dinocap)', quantity: '250ml', price_rupees: 350, in_stock: true },

  // Spider Mites
  { disease_key: 'spider_mites', name: 'Neem Oil (organic)', quantity: '500ml', price_rupees: 220, in_stock: true },
  { disease_key: 'spider_mites', name: 'Abamectin 1.9% EC', quantity: '100ml', price_rupees: 280, in_stock: true },

  // Bacterial Spot
  { disease_key: 'bacterial_spot', name: 'Copper Oxychloride 50% WP', quantity: '500g', price_rupees: 240, in_stock: true },
  { disease_key: 'bacterial_spot', name: 'Streptomycin Sulphate', quantity: '100g', price_rupees: 350, in_stock: true },

  // Black Rot
  { disease_key: 'black_rot', name: 'Mancozeb 75% WP', quantity: '500g', price_rupees: 180, in_stock: true },
  { disease_key: 'black_rot', name: 'Copper Oxychloride 50% WP', quantity: '500g', price_rupees: 240, in_stock: true },

  // Bacterial Blight
  { disease_key: 'bacterial_blight', name: 'Copper Oxychloride 50% WP', quantity: '500g', price_rupees: 240, in_stock: true },
  { disease_key: 'bacterial_blight', name: 'Streptomycin Sulphate', quantity: '100g', price_rupees: 350, in_stock: true },

  // Default (fallback)
  { disease_key: 'default', name: 'Mancozeb 75% WP', quantity: '500g', price_rupees: 180, in_stock: true },
  { disease_key: 'default', name: 'Neem Oil (organic)', quantity: '500ml', price_rupees: 220, in_stock: true },
];

const shops = [
  {
    name: 'Patil Krushi Kendra',
    distance_km: 2.3,
    address: 'Near Bus Stand, Baramati',
    phone_number: '9876543210',
  },
  {
    name: 'Sharma Agri Store',
    distance_km: 4.1,
    address: 'Main Road, Indapur',
    phone_number: '9123456789',
  },
  {
    name: 'Mauli Agro Services',
    distance_km: 6.8,
    address: 'Pune-Solapur Highway, Daund',
    phone_number: '9988776655',
  },
];

const scans = [
  { user_id: 'default_user', crop_name: 'Tomato', disease_name: 'Early Blight', confidence: 0.87, status: 'active', image_url: 'assets/images/early_blight_leaf.png', treatment_applied: null, scanned_at: '2026-04-05T10:30:00Z' },
  { user_id: 'default_user', crop_name: 'Tomato', disease_name: 'Healthy', confidence: 0.95, status: 'resolved', image_url: 'assets/images/healthy_leaf.png', treatment_applied: null, scanned_at: '2026-03-28T09:15:00Z' },
  { user_id: 'default_user', crop_name: 'Onion', disease_name: 'Powdery Mildew', confidence: 0.79, status: 'resolved', image_url: 'assets/images/healthy_leaf.png', treatment_applied: 'Sulphur spray', scanned_at: '2026-03-15T14:00:00Z' },
  { user_id: 'default_user', crop_name: 'Tomato', disease_name: 'Late Blight', confidence: 0.92, status: 'resolved', image_url: 'assets/images/early_blight_leaf.png', treatment_applied: 'Metalaxyl + Mancozeb', scanned_at: '2026-02-22T11:45:00Z' },
  { user_id: 'default_user', crop_name: 'Cotton', disease_name: 'Bacterial Blight', confidence: 0.84, status: 'resolved', image_url: 'assets/images/early_blight_leaf.png', treatment_applied: 'Copper oxychloride', scanned_at: '2026-01-18T08:30:00Z' },
  { user_id: 'default_user', crop_name: 'Soybean', disease_name: 'Bacterial Blight', confidence: 0.81, status: 'resolved', image_url: 'assets/images/early_blight_leaf.png', treatment_applied: 'Streptomycin sulphate', scanned_at: '2025-10-12T10:00:00Z' },
  { user_id: 'default_user', crop_name: 'Cotton', disease_name: 'Healthy', confidence: 0.96, status: 'resolved', image_url: 'assets/images/healthy_leaf.png', treatment_applied: null, scanned_at: '2025-09-05T09:00:00Z' },
  { user_id: 'default_user', crop_name: 'Soybean', disease_name: 'Powdery Mildew', confidence: 0.73, status: 'resolved', image_url: 'assets/images/healthy_leaf.png', treatment_applied: 'Wettable sulphur', scanned_at: '2025-08-18T16:00:00Z' },
  { user_id: 'default_user', crop_name: 'Cotton', disease_name: 'Early Blight', confidence: 0.88, status: 'resolved', image_url: 'assets/images/early_blight_leaf.png', treatment_applied: 'Mancozeb spray', scanned_at: '2025-07-02T07:30:00Z' },
];

const communityAlerts = [
  { farmer_name: 'Ramesh Patil', village_name: 'Mandavgan', disease_name: 'Early Blight', crop_name: 'Tomato', distance_km: 1.8, map_x: 0.55, map_y: 0.35, severity_color: 'danger', reported_at: new Date(Date.now() - 3 * 3600000).toISOString() },
  { farmer_name: 'Sunita Jadhav', village_name: 'Loni Kalbhor', disease_name: 'Early Blight', crop_name: 'Tomato', distance_km: 3.2, map_x: 0.3, map_y: 0.55, severity_color: 'danger', reported_at: new Date(Date.now() - 8 * 3600000).toISOString() },
  { farmer_name: 'Vijay Shinde', village_name: 'Uruli Kanchan', disease_name: 'Powdery Mildew', crop_name: 'Onion', distance_km: 4.5, map_x: 0.72, map_y: 0.6, severity_color: 'warning', reported_at: new Date(Date.now() - 14 * 3600000).toISOString() },
  { farmer_name: 'Anil More', village_name: 'Jejuri', disease_name: 'Late Blight', crop_name: 'Tomato', distance_km: 6.1, map_x: 0.2, map_y: 0.75, severity_color: 'danger', reported_at: new Date(Date.now() - 24 * 3600000).toISOString() },
  { farmer_name: 'Priya Kulkarni', village_name: 'Saswad', disease_name: 'Healthy', crop_name: 'Soybean', distance_km: 5.4, map_x: 0.8, map_y: 0.28, severity_color: 'safe', reported_at: new Date(Date.now() - 30 * 3600000).toISOString() },
];

// ─── Seed Functions ────────────────────────────────────────────

async function seedTable(tableName, data) {
  console.log(`  Seeding ${tableName}... (${data.length} records)`);

  // Delete existing data first
  const { error: deleteError } = await supabase.from(tableName).delete().neq('id', '00000000-0000-0000-0000-000000000000');

  if (deleteError) {
    console.warn(`  ⚠️  Could not clear ${tableName}: ${deleteError.message}`);
  }

  // Insert new data
  const { data: inserted, error } = await supabase.from(tableName).insert(data).select();

  if (error) {
    console.error(`  ❌ Failed to seed ${tableName}: ${error.message}`);
    return false;
  }

  console.log(`  ✅ ${tableName}: ${inserted.length} records inserted`);
  return true;
}

async function main() {
  console.log('\n🌱 CropDoc Database Seeder');
  console.log('─'.repeat(40));

  if (!process.env.SUPABASE_URL || process.env.SUPABASE_URL.includes('your-project-id')) {
    console.error('\n❌ Supabase URL not configured!');
    console.error('   Edit backend/.env with your Supabase credentials first.');
    console.error('   Then run the SQL schema in Supabase SQL Editor.');
    console.error('   Then run: npm run seed\n');
    process.exit(1);
  }

  console.log(`  Supabase: ${process.env.SUPABASE_URL}\n`);

  let allSuccess = true;

  allSuccess = (await seedTable('diseases', diseases)) && allSuccess;
  allSuccess = (await seedTable('treatments', treatments)) && allSuccess;
  allSuccess = (await seedTable('products', products)) && allSuccess;
  allSuccess = (await seedTable('shops', shops)) && allSuccess;
  allSuccess = (await seedTable('scans', scans)) && allSuccess;
  allSuccess = (await seedTable('community_alerts', communityAlerts)) && allSuccess;

  console.log('\n' + '─'.repeat(40));
  if (allSuccess) {
    console.log('✅ All tables seeded successfully!');
  } else {
    console.log('⚠️  Some tables failed to seed. Check errors above.');
  }
  console.log('');
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
