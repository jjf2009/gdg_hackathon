const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');
const { requireFields } = require('../middleware/validate');

// ─── GET /api/community/alerts ─────────────────────────────────
// Get community disease alerts, optionally filter by radius
router.get(
  '/alerts',
  asyncHandler(async (req, res) => {
    const { limit = 50 } = req.query;

    const { data, error } = await supabase
      .from('community_alerts')
      .select('*')
      .order('reported_at', { ascending: false })
      .limit(parseInt(limit));

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data: data || [] });
  })
);

// ─── GET /api/community/trends ─────────────────────────────────
// Get disease trends from recent alerts
router.get(
  '/trends',
  asyncHandler(async (req, res) => {
    // Get alerts from the past 7 days
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    const { data, error } = await supabase
      .from('community_alerts')
      .select('*')
      .neq('disease_name', 'Healthy')
      .gte('reported_at', oneWeekAgo.toISOString());

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    // Aggregate trends
    const trendMap = {};
    (data || []).forEach((alert) => {
      trendMap[alert.disease_name] = (trendMap[alert.disease_name] || 0) + 1;
    });

    const trends = Object.entries(trendMap)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([disease_name, count]) => ({
        disease_name,
        reports_this_week: count,
        change_percent: count > 5 ? 40 : count > 2 ? 10 : -20,
        trend: count > 5 ? 'rising' : count > 2 ? 'stable' : 'declining',
      }));

    res.json({
      success: true,
      data: {
        trends,
        total_reports: (data || []).length,
      },
    });
  })
);

// ─── POST /api/community/alerts ────────────────────────────────
// Report a new disease alert
router.post(
  '/alerts',
  requireFields('farmer_name', 'disease_name', 'crop_name'),
  asyncHandler(async (req, res) => {
    const {
      user_id,
      farmer_name,
      village_name = 'Unknown',
      disease_name,
      crop_name,
      distance_km = 0,
      map_x = 0.5,
      map_y = 0.5,
      severity_color = 'danger',
    } = req.body;

    const insertData = {
      farmer_name,
      village_name,
      disease_name,
      crop_name,
      distance_km: parseFloat(distance_km),
      map_x: parseFloat(map_x),
      map_y: parseFloat(map_y),
      severity_color,
      reported_at: new Date().toISOString(),
    };

    // Add user_id if provided (column may not exist in older schemas)
    if (user_id) {
      insertData.user_id = user_id;
    }

    const { data, error } = await supabase
      .from('community_alerts')
      .insert(insertData)
      .select()
      .single();

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.status(201).json({ success: true, data });
  })
);

// ─── DELETE /api/community/alerts/:id ──────────────────────────
// Delete a community alert
router.delete(
  '/alerts/:id',
  asyncHandler(async (req, res) => {
    const { id } = req.params;

    const { error } = await supabase.from('community_alerts').delete().eq('id', id);

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, message: 'Alert deleted' });
  })
);

module.exports = router;
