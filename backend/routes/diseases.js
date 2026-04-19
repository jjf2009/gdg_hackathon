const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');

// ─── GET /api/diseases ─────────────────────────────────────────
// List all diseases, optionally filter by crop_name
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { crop_name } = req.query;

    let query = supabase
      .from('diseases')
      .select('*')
      .order('crop_name', { ascending: true });

    if (crop_name) {
      query = query.ilike('crop_name', crop_name);
    }

    const { data, error } = await query;

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

// ─── GET /api/diseases/lookup/:cropName/:diseaseName ───────────
// Find a specific disease by crop + disease name
router.get(
  '/lookup/:cropName/:diseaseName',
  asyncHandler(async (req, res) => {
    const { cropName, diseaseName } = req.params;

    const { data, error } = await supabase
      .from('diseases')
      .select('*')
      .ilike('crop_name', cropName)
      .ilike('name', diseaseName.replace(/_/g, ' '))
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({
        success: false,
        error: { message: `Disease "${diseaseName}" not found for crop "${cropName}"` },
      });
    }
    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

// ─── GET /api/diseases/:id ─────────────────────────────────────
// Get a single disease by UUID
router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('diseases')
      .select('*')
      .eq('id', id)
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({
        success: false,
        error: { message: 'Disease not found' },
      });
    }
    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

module.exports = router;
