const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');

// ─── GET /api/shops ────────────────────────────────────────────
// List all shops, ordered by distance
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { data, error } = await supabase
      .from('shops')
      .select('*')
      .order('distance_km', { ascending: true });

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data: data || [] });
  })
);

// ─── GET /api/shops/:id ────────────────────────────────────────
// Get a single shop by ID
router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('shops')
      .select('*')
      .eq('id', id)
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({
        success: false,
        error: { message: 'Shop not found' },
      });
    }
    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

module.exports = router;
