import 'package:flutter/material.dart';

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
