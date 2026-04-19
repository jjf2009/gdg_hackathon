const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');

// ─── GET /api/treatments/:diseaseKey ───────────────────────────
// Get treatment steps for a disease (ordered by step_order)
router.get(
  '/:diseaseKey',
  asyncHandler(async (req, res) => {
    const { diseaseKey } = req.params;

    const { data, error } = await supabase
      .from('treatments')
      .select('*')
      .eq('disease_key', diseaseKey.toLowerCase())
      .order('step_order', { ascending: true });

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    // If no data found in DB, return from the static fallback
    if (!data || data.length === 0) {
      return res.json({
        success: true,
        data: _getDefaultSteps(),
        source: 'fallback',
      });
    }

    res.json({ success: true, data });
  })
);

// ─── GET /api/treatments/:diseaseKey/products ──────────────────
// Get recommended products for a disease
router.get(
  '/:diseaseKey/products',
  asyncHandler(async (req, res) => {
    const { diseaseKey } = req.params;

    let { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('disease_key', diseaseKey.toLowerCase());

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    // Fallback to default products if none found
    if (!data || data.length === 0) {
      const fallback = await supabase
        .from('products')
        .select('*')
        .eq('disease_key', 'default');

      data = fallback.data || [];
    }

    res.json({ success: true, data });
  })
);

// ─── GET /api/treatments/:diseaseKey/schedule ──────────────────
// Generate a treatment/spray schedule based on disease type
router.get(
  '/:diseaseKey/schedule',
  asyncHandler(async (req, res) => {
    const diseaseKey = req.params.diseaseKey.toLowerCase();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const schedule = _generateSchedule(diseaseKey, today);

    res.json({ success: true, data: schedule });
  })
);

// ─── GET /api/treatments/:diseaseKey/shops ─────────────────────
// Get nearby shops with products for a disease
router.get(
  '/:diseaseKey/shops',
  asyncHandler(async (req, res) => {
    const { diseaseKey } = req.params;

    // Get shops
    const { data: shops, error: shopError } = await supabase
      .from('shops')
      .select('*')
      .order('distance_km', { ascending: true });

    if (shopError) throw Object.assign(new Error(shopError.message), { statusCode: 500 });

    // Get products for this disease
    let { data: products, error: prodError } = await supabase
      .from('products')
      .select('*')
      .eq('disease_key', diseaseKey.toLowerCase());

    if (prodError) throw Object.assign(new Error(prodError.message), { statusCode: 500 });

    if (!products || products.length === 0) {
      const fallback = await supabase
        .from('products')
        .select('*')
        .eq('disease_key', 'default');
      products = fallback.data || [];
    }

    // Pair shops with products (with slight price variation per shop)
    const shopData = (shops || []).map((shop, idx) => {
      const multiplier = [1.0, 0.95, 1.05][idx % 3];
      return {
        ...shop,
        products: products.map((p) => ({
          ...p,
          price_rupees: Math.round(p.price_rupees * multiplier),
        })),
      };
    });

    res.json({ success: true, data: shopData });
  })
);

// ─── Fallback helpers ──────────────────────────────────────────

function _getDefaultSteps() {
  return [
    {
      step_order: 1,
      icon_name: 'sanitizer_rounded',
      instruction: 'Apply appropriate fungicide based on disease type',
      urgency_label: 'Do today',
      detail:
        'Consult your local agricultural officer for the specific fungicide recommendation for this disease.',
    },
    {
      step_order: 2,
      icon_name: 'content_cut_rounded',
      instruction: 'Remove all visibly affected plant parts',
      urgency_label: 'Do today',
      detail:
        'Cut and remove infected leaves, stems, or fruit. Destroy them — do not leave on the field.',
    },
    {
      step_order: 3,
      icon_name: 'water_drop_rounded',
      instruction: 'Adjust watering and improve drainage',
      urgency_label: 'Ongoing',
      detail:
        'Avoid overhead watering. Ensure good field drainage to reduce favorable conditions for disease.',
    },
  ];
}

function _addDays(date, days) {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  return d.toISOString();
}

function _generateSchedule(diseaseKey, today) {
  if (diseaseKey === 'healthy') {
    return [
      { date: _addDays(today, 7), action_key: 'recheck', note: 'Routine health check', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'spray', note: 'Preventive Neem Oil spray', is_urgent: false },
      { date: _addDays(today, 21), action_key: 'recheck', note: 'Pre-harvest inspection', is_urgent: false },
      { date: _addDays(today, 28), action_key: 'harvest', note: 'Expected harvest window', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('blight')) {
    const sprayName = diseaseKey.includes('late')
      ? 'Metalaxyl + Mancozeb spray'
      : 'Mancozeb evening spray';
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: sprayName, is_urgent: true },
      { date: _addDays(today, 1), action_key: 'rest', note: null, is_urgent: false },
      { date: _addDays(today, 2), action_key: 'rest', note: null, is_urgent: false },
      { date: _addDays(today, 3), action_key: 'recheck', note: 'Check treated leaves', is_urgent: false },
      { date: _addDays(today, 5), action_key: 'spray', note: `Follow-up ${sprayName}`, is_urgent: false },
      { date: _addDays(today, 7), action_key: 'recheck', note: 'Assess treatment progress', is_urgent: false },
      { date: _addDays(today, 10), action_key: 'spray', note: 'Final preventive spray', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'recheck', note: 'Final disease check', is_urgent: false },
      { date: _addDays(today, 21), action_key: 'harvest', note: 'Safe harvest window opens', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('mildew')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Sulphur spray (morning)', is_urgent: true },
      { date: _addDays(today, 3), action_key: 'recheck', note: 'Check mildew spread', is_urgent: false },
      { date: _addDays(today, 7), action_key: 'spray', note: 'Follow-up Sulphur spray', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'recheck', note: 'Assess recovery', is_urgent: false },
      { date: _addDays(today, 21), action_key: 'harvest', note: 'Safe harvest window', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('rot')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Mancozeb + Copper spray', is_urgent: true },
      { date: _addDays(today, 2), action_key: 'recheck', note: 'Remove any new rot', is_urgent: false },
      { date: _addDays(today, 7), action_key: 'spray', note: 'Second spray application', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'recheck', note: 'Final inspection', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('spot')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Chlorothalonil spray', is_urgent: true },
      { date: _addDays(today, 3), action_key: 'recheck', note: 'Check for new spots', is_urgent: false },
      { date: _addDays(today, 7), action_key: 'spray', note: 'Follow-up spray', is_urgent: false },
      { date: _addDays(today, 10), action_key: 'recheck', note: 'Assess treatment', is_urgent: false },
      { date: _addDays(today, 21), action_key: 'harvest', note: 'Harvest window', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('mold')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Chlorothalonil spray', is_urgent: true },
      { date: _addDays(today, 1), action_key: 'recheck', note: 'Check ventilation improved', is_urgent: false },
      { date: _addDays(today, 7), action_key: 'spray', note: 'Second spray if needed', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'recheck', note: 'Final check', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('virus') || diseaseKey.includes('curl')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Insecticide for vector control', is_urgent: true },
      { date: _addDays(today, 1), action_key: 'recheck', note: 'Remove infected plants', is_urgent: false },
      { date: _addDays(today, 3), action_key: 'recheck', note: 'Check for new infections', is_urgent: false },
      { date: _addDays(today, 7), action_key: 'spray', note: 'Follow-up insecticide', is_urgent: false },
      { date: _addDays(today, 14), action_key: 'recheck', note: 'Monitor healthy plants', is_urgent: false },
    ];
  }

  if (diseaseKey.includes('scab')) {
    return [
      { date: _addDays(today, 0), action_key: 'spray', note: 'Mancozeb spray', is_urgent: true },
      { date: _addDays(today, 5), action_key: 'recheck', note: 'Check leaf condition', is_urgent: false },
      { date: _addDays(today, 10), action_key: 'spray', note: 'Preventive spray', is_urgent: false },
      { date: _addDays(today, 21), action_key: 'harvest', note: 'Harvest assessment', is_urgent: false },
    ];
  }

  // Default schedule
  return [
    { date: _addDays(today, 0), action_key: 'spray', note: 'Apply recommended treatment', is_urgent: true },
    { date: _addDays(today, 3), action_key: 'recheck', note: 'Check treatment effect', is_urgent: false },
    { date: _addDays(today, 7), action_key: 'spray', note: 'Follow-up spray', is_urgent: false },
    { date: _addDays(today, 14), action_key: 'recheck', note: 'Final disease check', is_urgent: false },
    { date: _addDays(today, 21), action_key: 'harvest', note: 'Safe harvest window', is_urgent: false },
  ];
}

module.exports = router;
