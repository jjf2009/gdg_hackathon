import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_info.dart';
import '../services/scan_history_service.dart';

/// Fallback weather that generates plausible data when API is unavailable.
/// Returns LiveWeatherData so the dashboard can use it seamlessly.
class DummyWeather {
  DummyWeather._();

  static LiveWeatherData get current {
    final now = DateTime.now();
    final rng = Random(now.day + now.hour ~/ 6);

    final baseTemp = 25 + (now.month >= 4 && now.month <= 9 ? 8 : 2);
    final temp = baseTemp + rng.nextInt(6) - 2;
    final feelsLike = temp + 2;

    final baseHumidity = now.month >= 6 && now.month <= 9 ? 80 : 55;
    final humidity = baseHumidity + rng.nextInt(20) - 5;

    final windSpeed = 5.0 + rng.nextInt(20);

    final String condition;
    final IconData icon;
    if (humidity > 85) {
      condition = 'Rain';
      icon = Icons.water_drop_rounded;
    } else if (humidity > 70) {
      condition = 'Clouds';
      icon = Icons.cloud_rounded;
    } else if (humidity > 55) {
      condition = 'Haze';
      icon = Icons.cloud_queue_rounded;
    } else {
      condition = 'Clear';
      icon = Icons.wb_sunny_rounded;
    }

    // Generate hourly rain data
    List<HourlyRain> hourlyRain = [];
    for (int i = 0; i < 12; i++) {
      final hour = (now.hour + i * 3) % 24;
      final chance = humidity > 70
          ? (0.3 + rng.nextDouble() * 0.5)
          : (rng.nextDouble() * 0.3);
      hourlyRain.add(HourlyRain(
        hour: hour,
        rainChance: chance,
        rainMm: chance > 0.5 ? (rng.nextDouble() * 5) : 0,
      ));
    }

    int? rainExpectedInHours;
    for (int i = 0; i < hourlyRain.length; i++) {
      if (hourlyRain[i].rainChance > 0.5) {
        rainExpectedInHours = (i + 1) * 3;
        break;
      }
    }

    // Daily humidity
    final dayNames = ['Today', 'Tomorrow', 'Day 3'];
    List<DailyHumidity> dailyHumidity = List.generate(3, (i) {
      final dayHumidity = humidity + rng.nextInt(15) - 7;
      return DailyHumidity(
        dayLabel: dayNames[i],
        humidity: dayHumidity.clamp(30, 100),
        tempHigh: temp + rng.nextInt(4),
        tempLow: temp - 3 - rng.nextInt(3),
        condition: dayHumidity > 75 ? 'Rain' : 'Clear',
      );
    });

    // Advisories
    String sprayAdvisory;
    if (rainExpectedInHours != null && rainExpectedInHours <= 4) {
      sprayAdvisory = "Rain expected in ${rainExpectedInHours}hrs — don't spray today.";
    } else if (windSpeed > 20) {
      sprayAdvisory = "High wind (${windSpeed.round()} km/h) — spray drift risk.";
    } else {
      sprayAdvisory = "Good conditions for spraying — low wind, no rain expected.";
    }

    String windAdvisory;
    if (windSpeed > 20) {
      windAdvisory = "High wind ${windSpeed.round()} km/h — spray drift risk.";
    } else {
      windAdvisory = "Calm wind ${windSpeed.round()} km/h — good for field operations.";
    }

    // Disease risk
    final records = ScanHistoryService.instance.records;
    final activeIssues = records.where(
      (r) => r.status == 'active' && r.diseaseName != 'Healthy',
    ).toList();

    String diseaseLevel;
    String diseaseMsg;
    if (activeIssues.isNotEmpty && humidity > 75) {
      diseaseLevel = 'high';
      diseaseMsg = 'Active ${activeIssues.first.diseaseName} + high humidity — act now.';
    } else if (humidity > 78) {
      diseaseLevel = 'high';
      diseaseMsg = 'High humidity ($humidity%) — fungal disease risk. Scan crops.';
    } else if (humidity > 65) {
      diseaseLevel = 'medium';
      diseaseMsg = '$temp°C with moderate humidity — keep monitoring.';
    } else {
      diseaseLevel = 'low';
      diseaseMsg = 'Low disease risk — conditions favorable.';
    }

    return LiveWeatherData(
      locationName: 'Local (Offline)',
      condition: condition,
      description: 'Simulated weather data',
      tempCelsius: temp,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeedKmh: windSpeed,
      icon: icon,
      rainExpectedInHours: rainExpectedInHours,
      hourlyRain: hourlyRain,
      dailyHumidity: dailyHumidity,
      sprayAdvisory: sprayAdvisory,
      windAdvisory: windAdvisory,
      diseaseRiskLevel: diseaseLevel,
      diseaseRiskMessage: diseaseMsg,
      lastUpdated: DateTime.now(),
      isLive: false,
    );
  }
}
