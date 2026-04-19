const express = require('express');
const router = express.Router();
const supabase = require('../config/supabase');
const { asyncHandler } = require('../middleware/errorHandler');
const { requireFields } = require('../middleware/validate');

// ─── GET /api/scans ────────────────────────────────────────────
// Get scan history for a user, with optional season filter
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { user_id, season, limit = 50 } = req.query;

    let query = supabase
      .from('scans')
      .select('*')
      .order('scanned_at', { ascending: false })
      .limit(parseInt(limit));

    if (user_id) {
      query = query.eq('user_id', user_id);
    }

    const { data, error } = await query;

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    // Filter by season if requested (Kharif: Jun-Nov, Rabi: Dec-May)
    let filtered = data || [];
    if (season) {
      filtered = filtered.filter((scan) => {
        const month = new Date(scan.scanned_at).getMonth() + 1;
        if (season.toLowerCase() === 'kharif') return month >= 6 && month <= 11;
        if (season.toLowerCase() === 'rabi') return month <= 5 || month === 12;
        return true;
      });
    }

    res.json({ success: true, data: filtered });
  })
);

// ─── GET /api/scans/stats ──────────────────────────────────────
// Get scan statistics for a user
router.get(
  '/stats',
  asyncHandler(async (req, res) => {
    const { user_id, season } = req.query;

    let query = supabase.from('scans').select('*');

    if (user_id) {
      query = query.eq('user_id', user_id);
    }

    const { data, error } = await query;

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    let records = data || [];

    // Filter by season
    if (season) {
      records = records.filter((scan) => {
        const month = new Date(scan.scanned_at).getMonth() + 1;
        if (season.toLowerCase() === 'kharif') return month >= 6 && month <= 11;
        if (season.toLowerCase() === 'rabi') return month <= 5 || month === 12;
        return true;
      });
    }

    const totalScans = records.length;
    const diseasesFound = records.filter((r) => r.disease_name !== 'Healthy').length;
    const resolved = records.filter((r) => r.status === 'resolved').length;
    const resolvedPercent = totalScans > 0 ? Math.round((resolved / totalScans) * 100) : 0;

    // Crop breakdown
    const cropCounts = {};
    records.forEach((r) => {
      cropCounts[r.crop_name] = (cropCounts[r.crop_name] || 0) + 1;
    });

    // Disease breakdown
    const diseaseCounts = {};
    records
      .filter((r) => r.disease_name !== 'Healthy')
      .forEach((r) => {
        diseaseCounts[r.disease_name] = (diseaseCounts[r.disease_name] || 0) + 1;
      });

    res.json({
      success: true,
      data: {
        total_scans: totalScans,
        diseases_found: diseasesFound,
        resolved,
        resolved_percent: resolvedPercent,
        crops: cropCounts,
        diseases: diseaseCounts,
      },
    });
  })
);

// ─── POST /api/scans ───────────────────────────────────────────
// Create a new scan record
router.post(
  '/',
  requireFields('crop_name', 'disease_name', 'confidence'),
  asyncHandler(async (req, res) => {
    const {
      user_id = 'default_user',
      crop_name,
      disease_name,
      confidence,
      status,
      image_url,
      treatment_applied,
    } = req.body;

    const isHealthy = disease_name.toLowerCase() === 'healthy';

    const { data, error } = await supabase
      .from('scans')
      .insert({
        user_id,
        crop_name,
        disease_name,
        confidence: parseFloat(confidence),
        status: status || (isHealthy ? 'resolved' : 'active'),
        image_url: image_url || null,
        treatment_applied: treatment_applied || null,
        scanned_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.status(201).json({ success: true, data });
  })
);

// ─── PATCH /api/scans/:id ──────────────────────────────────────
// Update a scan record (mark treated, change status)
router.patch(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const updates = {};

    // Only allow specific fields to be updated
    const allowedFields = ['status', 'treatment_applied'];
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'No valid fields to update. Allowed: ' + allowedFields.join(', ') },
      });
    }

    const { data, error } = await supabase
      .from('scans')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({
        success: false,
        error: { message: 'Scan record not found' },
      });
    }
    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, data });
  })
);

// ─── DELETE /api/scans/:id ─────────────────────────────────────
// Delete a scan record
router.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = req.params;

    const { error } = await supabase.from('scans').delete().eq('id', id);

    if (error) throw Object.assign(new Error(error.message), { statusCode: 500 });

    res.json({ success: true, message: 'Scan record deleted' });
  })
);

module.exports = router;
