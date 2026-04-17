import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_info.dart';
import '../services/scan_history_service.dart';

/// Dynamic weather that adjusts risk messaging based on detected diseases.
/// Simulates realistic weather variation (since we don't have an API key)
/// but makes risk assessment dynamic based on actual scan results.
class DummyWeather {
  DummyWeather._();

  static WeatherInfo get current {
    final now = DateTime.now();
    final rng = Random(now.day + now.hour ~/ 6); // Changes 4x per day

    // Simulate weather with daily variation
    final baseTemp = 25 + (now.month >= 4 && now.month <= 9 ? 8 : 2); // Hotter in summer
    final temp = baseTemp + rng.nextInt(6) - 2;

    final baseHumidity = now.month >= 6 && now.month <= 9 ? 80 : 55; // Humid in monsoon
    final humidity = baseHumidity + rng.nextInt(20) - 5;

    // Weather condition based on humidity
    final String condition;
    final IconData icon;
    if (humidity > 85) {
      condition = 'Rainy';
      icon = Icons.water_drop_rounded;
    } else if (humidity > 70) {
      condition = 'Partly Cloudy';
      icon = Icons.cloud_rounded;
    } else if (humidity > 55) {
      condition = 'Hazy';
      icon = Icons.cloud_queue_rounded;
    } else {
      condition = 'Sunny';
      icon = Icons.wb_sunny_rounded;
    }

    // Risk assessment based on ACTUAL scan history
    final records = ScanHistoryService.instance.records;
    final activeIssues = records.where((r) =>
        r.status == 'active' && r.diseaseName != 'Healthy').toList();
    final lastPrediction = ScanHistoryService.instance.lastPrediction;

    String riskLevel;
    String riskMessage;

    if (activeIssues.isNotEmpty) {
      final diseaseName = activeIssues.first.diseaseName;
      if (humidity > 75) {
        riskLevel = 'high';
        riskMessage = 'High humidity ($humidity%) — $diseaseName can spread fast. Act now.';
      } else if (temp > 30) {
        riskLevel = 'medium';
        riskMessage = 'Warm conditions (${temp}C) with active $diseaseName — monitor daily.';
      } else {
        riskLevel = 'medium';
        riskMessage = 'Active $diseaseName detected — follow treatment schedule.';
      }
    } else if (lastPrediction != null && lastPrediction.isHealthy) {
      if (humidity > 80) {
        riskLevel = 'medium';
        riskMessage = 'High humidity ($humidity%) — good time for preventive spray.';
      } else {
        riskLevel = 'low';
        riskMessage = 'Good conditions. ${temp}C, ${humidity}% humidity — plants look healthy.';
      }
    } else {
      // Default — no scans yet
      if (humidity > 78) {
        riskLevel = 'high';
        riskMessage = 'High humidity ($humidity%) today — risk of fungal disease. Scan your crops.';
      } else if (humidity > 65) {
        riskLevel = 'medium';
        riskMessage = '${temp}C with moderate humidity — keep monitoring.';
      } else {
        riskLevel = 'low';
        riskMessage = 'Clear conditions (${temp}C, ${humidity}%) — low disease risk.';
      }
    }

    return WeatherInfo(
      condition: condition,
      tempCelsius: temp,
      humidity: humidity,
      riskLevel: riskLevel,
      riskMessage: riskMessage,
      icon: icon,
    );
  }
}
