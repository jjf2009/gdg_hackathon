import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_info.dart';
import '../services/scan_history_service.dart';

class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  // ── OpenWeatherMap free tier (Current + Forecast) ──
  // Replace with your own key from https://openweathermap.org/api
  static const String _apiKey = '4cca3574a10d08137b7e7e5efef8a0eb';

  // Cache
  LiveWeatherData? _cachedData;
  DateTime? _lastFetch;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // Default fallback (Pune, India)
  static const double _defaultLat = 18.5204;
  static const double _defaultLon = 73.8567;

  bool get hasCachedData => _cachedData != null;
  LiveWeatherData? get cachedData => _cachedData;

  /// Main entry: fetch live weather, or return cache, or fallback.
  Future<LiveWeatherData> getWeather({bool forceRefresh = false}) async {
    // Return cache if fresh
    if (!forceRefresh &&
        _cachedData != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheExpiry) {
      return _cachedData!;
    }

    try {
      // Get device location
      final position = await _getPosition();
      final lat = position?.latitude ?? _defaultLat;
      final lon = position?.longitude ?? _defaultLon;

      // Resolve location name
      String locationName = 'Your Location';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          locationName = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? 'Your Location';
        }
      } catch (_) {}

      // Fetch weather from API
      final data = await _fetchWeather(lat, lon, locationName);
      _cachedData = data;
      _lastFetch = DateTime.now();
      return data;
    } catch (e) {
      // API failed — return cached or fallback
      if (_cachedData != null) return _cachedData!;
      throw Exception('Weather fetch failed: $e');
    }
  }

  Future<Position?> _getPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<LiveWeatherData> _fetchWeather(double lat, double lon, String locationName) async {
    // Use Current Weather + 5-day/3-hour Forecast (both free tier)
    final currentUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&cnt=16',
    );

    final responses = await Future.wait([
      http.get(currentUrl),
      http.get(forecastUrl),
    ]);

    if (responses[0].statusCode != 200) {
      throw Exception('Weather API error: ${responses[0].statusCode}');
    }

    final current = jsonDecode(responses[0].body) as Map<String, dynamic>;
    Map<String, dynamic>? forecast;
    if (responses[1].statusCode == 200) {
      forecast = jsonDecode(responses[1].body) as Map<String, dynamic>;
    }

    return _parseWeather(current, forecast, locationName);
  }

  LiveWeatherData _parseWeather(
    Map<String, dynamic> current,
    Map<String, dynamic>? forecast,
    String locationName,
  ) {
    // ── Current conditions ──
    final main = current['main'] as Map<String, dynamic>;
    final wind = current['wind'] as Map<String, dynamic>;
    final weatherList = current['weather'] as List;
    final weather = weatherList.first as Map<String, dynamic>;

    final temp = (main['temp'] as num).round();
    final feelsLike = (main['feels_like'] as num).round();
    final humidity = (main['humidity'] as num).round();
    final windSpeed = ((wind['speed'] as num) * 3.6); // m/s -> km/h
    final windGust = wind['gust'] != null ? ((wind['gust'] as num) * 3.6) : null;

    final conditionMain = weather['main'] as String;
    final description = weather['description'] as String;
    final iconCode = weather['icon'] as String;

    // Rain in current
    double? rainMmNextHour;
    final rain = current['rain'] as Map<String, dynamic>?;
    if (rain != null) {
      rainMmNextHour = (rain['1h'] as num?)?.toDouble();
    }

    // ── Forecast: hourly rain + daily humidity ──
    List<HourlyRain> hourlyRain = [];
    List<DailyHumidity> dailyHumidity = [];
    int? rainExpectedInHours;

    if (forecast != null) {
      final list = forecast['list'] as List? ?? [];
      final now = DateTime.now();

      // Build hourly rain from 3-hour intervals
      for (int i = 0; i < list.length && i < 12; i++) {
        final item = list[i] as Map<String, dynamic>;
        final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
        final pop = (item['pop'] as num? ?? 0).toDouble();
        final itemRain = item['rain'] as Map<String, dynamic>?;
        final rainMm = (itemRain?['3h'] as num?)?.toDouble() ?? 0;

        hourlyRain.add(HourlyRain(
          hour: dt.hour,
          rainChance: pop,
          rainMm: rainMm,
        ));

        // Detect first rain occurrence
        if (rainExpectedInHours == null && pop > 0.5) {
          final hoursAway = dt.difference(now).inHours;
          if (hoursAway > 0) {
            rainExpectedInHours = hoursAway;
          }
        }
      }

      // Build daily humidity (group by day, up to 3 days)
      Map<String, List<Map<String, dynamic>>> dailyGroups = {};
      for (final item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(((item as Map<String, dynamic>)['dt'] as int) * 1000);
        final dayKey = '${dt.year}-${dt.month}-${dt.day}';
        dailyGroups.putIfAbsent(dayKey, () => []).add(item);
      }

      int dayIndex = 0;
      final dayNames = ['Today', 'Tomorrow'];
      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (final entry in dailyGroups.entries) {
        if (dayIndex >= 3) break;
        final items = entry.value;
        int avgHumidity = 0;
        int maxTemp = -100;
        int minTemp = 100;
        for (final item in items) {
          final m = item['main'] as Map<String, dynamic>;
          avgHumidity += (m['humidity'] as num).round();
          final t = (m['temp'] as num).round();
          if (t > maxTemp) maxTemp = t;
          if (t < minTemp) minTemp = t;
        }
        avgHumidity = (avgHumidity / items.length).round();

        String label;
        if (dayIndex < dayNames.length) {
          label = dayNames[dayIndex];
        } else {
          final dt = DateTime.fromMillisecondsSinceEpoch(
            (items.first['dt'] as int) * 1000,
          );
          label = weekDays[dt.weekday - 1];
        }

        final firstWeather = (items.first['weather'] as List).first as Map<String, dynamic>;
        dailyHumidity.add(DailyHumidity(
          dayLabel: label,
          humidity: avgHumidity,
          tempHigh: maxTemp,
          tempLow: minTemp,
          condition: firstWeather['main'] as String,
        ));
        dayIndex++;
      }
    }

    // ── Compute advisories ──
    final sprayAdvisory = _computeSprayAdvisory(rainExpectedInHours, rainMmNextHour, windSpeed);
    final windAdvisory = _computeWindAdvisory(windSpeed, windGust);
    final diseaseResult = _computeDiseaseRisk(humidity, dailyHumidity, temp);

    final icon = _mapWeatherIcon(iconCode, conditionMain);

    return LiveWeatherData(
      locationName: locationName,
      condition: conditionMain,
      description: description,
      tempCelsius: temp,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeedKmh: windSpeed,
      windGustKmh: windGust,
      icon: icon,
      rainExpectedInHours: rainExpectedInHours,
      rainMmNextHour: rainMmNextHour,
      hourlyRain: hourlyRain,
      dailyHumidity: dailyHumidity,
      sprayAdvisory: sprayAdvisory,
      windAdvisory: windAdvisory,
      diseaseRiskLevel: diseaseResult.$1,
      diseaseRiskMessage: diseaseResult.$2,
      lastUpdated: DateTime.now(),
      isLive: true,
    );
  }

  String _computeSprayAdvisory(int? rainInHours, double? rainNow, double windKmh) {
    if (rainNow != null && rainNow > 0) {
      return "It's raining now — don't spray, chemicals will wash off.";
    }
    if (rainInHours != null && rainInHours <= 4) {
      return "Rain expected in ${rainInHours}hrs — don't spray today.";
    }
    if (rainInHours != null && rainInHours <= 8) {
      return "Rain likely in ${rainInHours}hrs — spray early morning if needed.";
    }
    if (windKmh > 20) {
      return "High wind (${windKmh.round()} km/h) — spray drift risk. Wait.";
    }
    if (windKmh > 12) {
      return "Moderate wind — spray with care, prefer low nozzle pressure.";
    }
    return "Good conditions for spraying — low wind, no rain expected.";
  }

  String _computeWindAdvisory(double windKmh, double? gustKmh) {
    if (windKmh > 30 || (gustKmh != null && gustKmh > 40)) {
      return "Strong wind ${windKmh.round()} km/h — avoid spraying, secure loose covers.";
    }
    if (windKmh > 20) {
      return "High wind ${windKmh.round()} km/h — spray drift risk, wait for calm.";
    }
    if (windKmh > 12) {
      return "Moderate wind ${windKmh.round()} km/h — use low pressure nozzles.";
    }
    return "Calm wind ${windKmh.round()} km/h — good for all field operations.";
  }

  (String, String) _computeDiseaseRisk(int humidity, List<DailyHumidity> daily, int temp) {
    // Check scan history for active diseases
    final records = ScanHistoryService.instance.records;
    final activeIssues = records.where(
      (r) => r.status == 'active' && r.diseaseName != 'Healthy',
    ).toList();

    // Count high-humidity days in next 3
    int highHumidityDays = daily.where((d) => d.humidity > 75).length;

    if (activeIssues.isNotEmpty && humidity > 75) {
      return (
        'high',
        'Active ${activeIssues.first.diseaseName} + high humidity ($humidity%) — disease spreading fast. Act now!',
      );
    }

    if (highHumidityDays >= 2 && humidity > 70) {
      return (
        'high',
        'High humidity for $highHumidityDays of next 3 days → Late Blight & fungal disease risk.',
      );
    }

    if (humidity > 80) {
      return (
        'high',
        'Very high humidity ($humidity%) — fungal disease risk elevated. Preventive spray recommended.',
      );
    }

    if (humidity > 65 && temp > 25) {
      return (
        'medium',
        'Warm & humid ($temp°C, $humidity%) — monitor crops for early disease signs.',
      );
    }

    if (activeIssues.isNotEmpty) {
      return (
        'medium',
        'Active ${activeIssues.first.diseaseName} detected — continue treatment schedule.',
      );
    }

    return (
      'low',
      'Low disease risk — conditions are favorable. Keep monitoring.',
    );
  }

  IconData _mapWeatherIcon(String iconCode, String condition) {
    switch (condition.toLowerCase()) {
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'drizzle':
      case 'rain':
        return Icons.water_drop_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'clear':
        return iconCode.endsWith('n') ? Icons.nightlight_round : Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'mist':
      case 'haze':
      case 'fog':
        return Icons.cloud_queue_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  /// Fallback when everything fails
  LiveWeatherData _buildFallback() {
    return LiveWeatherData(
      locationName: 'Offline',
      condition: 'Unknown',
      description: 'Weather data unavailable',
      tempCelsius: 28,
      feelsLike: 30,
      humidity: 65,
      windSpeedKmh: 8,
      icon: Icons.cloud_off_rounded,
      hourlyRain: [],
      dailyHumidity: [],
      sprayAdvisory: 'Unable to fetch weather — check conditions manually before spraying.',
      windAdvisory: 'Wind data unavailable — check local conditions.',
      diseaseRiskLevel: 'medium',
      diseaseRiskMessage: 'Weather data unavailable — monitor crops visually for disease signs.',
      lastUpdated: DateTime.now(),
      isLive: false,
    );
  }
}
