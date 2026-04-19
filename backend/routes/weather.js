const express = require('express');
const router = express.Router();
const { asyncHandler } = require('../middleware/errorHandler');

// ─── GET /api/weather ──────────────────────────────────────────
// Simulated weather endpoint with disease-risk assessment.
// No external API key needed — generates realistic, deterministic
// weather based on date/time, matching the Flutter DummyWeather logic.
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const hour = now.getHours();

    // Deterministic "random" based on day + time block
    const seed = day + Math.floor(hour / 6);
    const pseudoRandom = ((seed * 9301 + 49297) % 233280) / 233280;

    // Temperature: hotter in summer (Apr-Sep), cooler otherwise
    const isSummer = month >= 4 && month <= 9;
    const baseTemp = 25 + (isSummer ? 8 : 2);
    const temp = Math.round(baseTemp + pseudoRandom * 6 - 2);

    // Humidity: very humid in monsoon (Jun-Sep)
    const isMonsoon = month >= 6 && month <= 9;
    const baseHumidity = isMonsoon ? 80 : 55;
    const humidity = Math.round(baseHumidity + pseudoRandom * 20 - 5);

    // Weather condition from humidity
    let condition, icon;
    if (humidity > 85) {
      condition = 'Rainy';
      icon = 'water_drop_rounded';
    } else if (humidity > 70) {
      condition = 'Partly Cloudy';
      icon = 'cloud_rounded';
    } else if (humidity > 55) {
      condition = 'Hazy';
      icon = 'cloud_queue_rounded';
    } else {
      condition = 'Sunny';
      icon = 'wb_sunny_rounded';
    }

    // Risk assessment
    let risk_level, risk_message;
    if (humidity > 78) {
      risk_level = 'high';
      risk_message = `High humidity (${humidity}%) today — risk of fungal disease. Scan your crops.`;
    } else if (humidity > 65) {
      risk_level = 'medium';
      risk_message = `${temp}°C with moderate humidity — keep monitoring.`;
    } else {
      risk_level = 'low';
      risk_message = `Clear conditions (${temp}°C, ${humidity}%) — low disease risk.`;
    }

    res.json({
      success: true,
      data: {
        condition,
        temp_celsius: temp,
        humidity,
        risk_level,
        risk_message,
        icon,
        timestamp: now.toISOString(),
        location: req.query.location || 'Baramati, Maharashtra',
      },
    });
  })
);

module.exports = router;
