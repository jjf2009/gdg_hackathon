const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');
const { requireFields } = require('../middleware/validate');

// ─── POST /api/auth/register ──────────────────────────────────
// Register a new user or update existing user's name.
// Uses phone as unique identifier (upsert).
router.post(
  '/register',
  requireFields('phone', 'display_name'),
  asyncHandler(async (req, res) => {
    const { phone, display_name } = req.body;

    // Upsert — create if new, update display_name if exists
    const { data, error } = await supabase
      .from('users')
      .upsert(
        { phone, display_name, last_login: new Date().toISOString() },
        { onConflict: 'phone' }
      )
      .select()
      .single();

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.status(201).json({ success: true, data });
  })
);

// ─── GET /api/auth/profile ────────────────────────────────────
// Get user profile by phone number
router.get(
  '/profile',
  asyncHandler(async (req, res) => {
    const { phone } = req.query;

    if (!phone) {
      return res.status(400).json({
        success: false,
        error: { message: 'phone query parameter is required' },
      });
    }

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('phone', phone)
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({
        success: false,
        error: { message: 'User not found' },
      });
    }
    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

module.exports = router;
