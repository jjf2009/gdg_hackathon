import 'package:flutter/material.dart';

/// Compact legacy model kept for backward compat with WeatherBanner.
class WeatherInfo {
  final String condition;
  final int tempCelsius;
  final int humidity;
  final String riskLevel; // 'low', 'medium', 'high'
  final String riskMessage;
  final IconData icon;

  const WeatherInfo({
    required this.condition,
    required this.tempCelsius,
    required this.humidity,
    required this.riskLevel,
    required this.riskMessage,
    required this.icon,
  });
}

/// Rich weather data for the hyper-local dashboard.
class LiveWeatherData {
  final String locationName;
  final String condition;       // e.g. "Partly Cloudy"
  final String description;     // e.g. "scattered clouds"
  final int tempCelsius;
  final int feelsLike;
  final int humidity;
  final double windSpeedKmh;
  final double? windGustKmh;
  final int? uvIndex;
  final IconData icon;

  // Rain forecast
  final int? rainExpectedInHours;  // null = no rain expected in 12hrs
  final double? rainMmNextHour;
  final List<HourlyRain> hourlyRain; // next 12 hours

  // Multi-day humidity for disease risk
  final List<DailyHumidity> dailyHumidity; // next 3 days

  // Computed advisories
  final String sprayAdvisory;
  final String windAdvisory;
  final String diseaseRiskLevel; // 'low', 'medium', 'high'
  final String diseaseRiskMessage;

  // Meta
  final DateTime lastUpdated;
  final bool isLive; // true = from API, false = fallback

  const LiveWeatherData({
    required this.locationName,
    required this.condition,
    required this.description,
    required this.tempCelsius,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeedKmh,
    this.windGustKmh,
    this.uvIndex,
    required this.icon,
    this.rainExpectedInHours,
    this.rainMmNextHour,
    this.hourlyRain = const [],
    this.dailyHumidity = const [],
    required this.sprayAdvisory,
    required this.windAdvisory,
    required this.diseaseRiskLevel,
    required this.diseaseRiskMessage,
    required this.lastUpdated,
    this.isLive = false,
  });

  /// Convert to legacy WeatherInfo
  WeatherInfo toWeatherInfo() {
    return WeatherInfo(
      condition: condition,
      tempCelsius: tempCelsius,
      humidity: humidity,
      riskLevel: diseaseRiskLevel,
      riskMessage: diseaseRiskMessage,
      icon: icon,
    );
  }
}

class HourlyRain {
  final int hour; // 0-23
  final double rainChance; // 0.0 - 1.0
  final double rainMm;

  const HourlyRain({
    required this.hour,
    required this.rainChance,
    required this.rainMm,
  });
}

class DailyHumidity {
  final String dayLabel; // "Today", "Tomorrow", "Wed"
  final int humidity;
  final int tempHigh;
  final int tempLow;
  final String condition;

  const DailyHumidity({
    required this.dayLabel,
    required this.humidity,
    required this.tempHigh,
    required this.tempLow,
    required this.condition,
  });
}
