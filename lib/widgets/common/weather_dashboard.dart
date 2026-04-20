import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/weather_info.dart';

class WeatherDashboard extends StatelessWidget {
  final LiveWeatherData weather;
  final VoidCallback onRefresh;
  final bool isLoading;

  const WeatherDashboard({
    super.key,
    required this.weather,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Current Conditions Hero Card ──
        _buildCurrentCard(context)
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.08),
        const SizedBox(height: 16),

        // ── Advisory Cards (horizontal scroll) ──
        _buildAdvisoryRow(context)
            .animate()
            .fadeIn(delay: 150.ms, duration: 500.ms)
            .slideY(begin: 0.08),
        const SizedBox(height: 16),

        // ── Hourly Rain Chart ──
        if (weather.hourlyRain.isNotEmpty) ...[
          _buildHourlyRainChart(context)
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.08),
          const SizedBox(height: 16),
        ],

        // ── 3-Day Humidity Outlook ──
        if (weather.dailyHumidity.isNotEmpty)
          _buildDailyHumidity(context)
              .animate()
              .fadeIn(delay: 450.ms, duration: 500.ms)
              .slideY(begin: 0.08),
      ],
    );
  }

  // ─────────── CURRENT CONDITIONS ───────────
  Widget _buildCurrentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: location + refresh
          Row(
            children: [
              Icon(
                weather.isLive ? Icons.location_on_rounded : Icons.cloud_off_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  weather.locationName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!weather.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Offline',
                    style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRefresh();
                },
                child: AnimatedRotation(
                  turns: isLoading ? 1 : 0,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main temp + condition
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.tempCelsius}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feels like ${weather.feelsLike}°C',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Icon + condition
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(weather.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.condition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(Icons.water_drop_outlined, '${weather.humidity}%', 'Humidity'),
                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.15)),
                _statItem(Icons.air_rounded, '${weather.windSpeedKmh.round()} km/h', 'Wind'),
                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.15)),
                _statItem(
                  weather.rainExpectedInHours != null
                      ? Icons.umbrella_rounded
                      : Icons.wb_sunny_outlined,
                  weather.rainExpectedInHours != null
                      ? '${weather.rainExpectedInHours}h'
                      : 'None',
                  'Rain',
                ),
              ],
            ),
          ),

          // Last updated
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.4), size: 11),
              const SizedBox(width: 4),
              Text(
                'Updated ${_formatTime(weather.lastUpdated)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ─────────── ADVISORY CARDS ───────────
  Widget _buildAdvisoryRow(BuildContext context) {
    final advisories = <_AdvisoryData>[
      // Spray advisory — always show
      _AdvisoryData(
        icon: weather.rainExpectedInHours != null
            ? Icons.umbrella_rounded
            : Icons.check_circle_outline_rounded,
        title: 'Spray Advisory',
        message: weather.sprayAdvisory,
        color: weather.rainExpectedInHours != null && weather.rainExpectedInHours! <= 4
            ? const Color(0xFFE76F51)
            : weather.windSpeedKmh > 20
                ? const Color(0xFFE9C46A)
                : CropDocColors.safe,
        bgColor: weather.rainExpectedInHours != null && weather.rainExpectedInHours! <= 4
            ? const Color(0xFFFFF0EB)
            : weather.windSpeedKmh > 20
                ? const Color(0xFFFFF8E1)
                : CropDocColors.safeLight,
      ),
      // Wind advisory
      _AdvisoryData(
        icon: Icons.air_rounded,
        title: 'Wind Status',
        message: weather.windAdvisory,
        color: weather.windSpeedKmh > 20
            ? const Color(0xFFE76F51)
            : weather.windSpeedKmh > 12
                ? const Color(0xFFE9C46A)
                : CropDocColors.safe,
        bgColor: weather.windSpeedKmh > 20
            ? const Color(0xFFFFF0EB)
            : weather.windSpeedKmh > 12
                ? const Color(0xFFFFF8E1)
                : CropDocColors.safeLight,
      ),
      // Disease risk
      _AdvisoryData(
        icon: Icons.coronavirus_rounded,
        title: 'Disease Risk',
        message: weather.diseaseRiskMessage,
        color: weather.diseaseRiskLevel == 'high'
            ? const Color(0xFFC1121F)
            : weather.diseaseRiskLevel == 'medium'
                ? const Color(0xFFE9C46A)
                : CropDocColors.safe,
        bgColor: weather.diseaseRiskLevel == 'high'
            ? const Color(0xFFFFE0E3)
            : weather.diseaseRiskLevel == 'medium'
                ? const Color(0xFFFFF8E1)
                : CropDocColors.safeLight,
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: advisories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final a = advisories[index];
          return _buildAdvisoryCard(a);
        },
      ),
    );
  }

  Widget _buildAdvisoryCard(_AdvisoryData data) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: data.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: data.color,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              data.message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: data.color.withValues(alpha: 0.85),
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── HOURLY RAIN CHART ───────────
  Widget _buildHourlyRainChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: Color(0xFF4895EF), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Rain Forecast',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CropDocColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                'Next ${weather.hourlyRain.length * 3}h',
                style: const TextStyle(
                  fontSize: 11,
                  color: CropDocColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weather.hourlyRain.map((hr) {
                final barHeight = (hr.rainChance * 60).clamp(4.0, 60.0);
                final isHigh = hr.rainChance > 0.5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(hr.rainChance * 100).round()}%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isHigh
                                ? const Color(0xFF4895EF)
                                : CropDocColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isHigh
                                  ? [const Color(0xFF4895EF), const Color(0xFF4361EE)]
                                  : [const Color(0xFFBDE0FE), const Color(0xFFA2D2FF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${hr.hour.toString().padLeft(2, '0')}h',
                          style: const TextStyle(
                            fontSize: 9,
                            color: CropDocColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── 3-DAY HUMIDITY OUTLOOK ───────────
  Widget _buildDailyHumidity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: CropDocColors.primary, size: 16),
              const SizedBox(width: 8),
              const Text(
                '3-Day Humidity Outlook',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: CropDocColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getDiseaseRiskColor(weather.diseaseRiskLevel).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${weather.diseaseRiskLevel.toUpperCase()} RISK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _getDiseaseRiskColor(weather.diseaseRiskLevel),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weather.dailyHumidity.map((day) {
            final isHigh = day.humidity > 75;
            final isMedium = day.humidity > 60;
            final barColor = isHigh
                ? const Color(0xFFE76F51)
                : isMedium
                    ? const Color(0xFFE9C46A)
                    : CropDocColors.safe;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      day.dayLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CropDocColors.textPrimary,
                      ),
                    ),
                  ),
                  // Humidity bar
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: CropDocColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: day.humidity / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [barColor.withValues(alpha: 0.6), barColor],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${day.humidity}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: barColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${day.tempHigh}°/${day.tempLow}°',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CropDocColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getDiseaseRiskColor(String level) {
    switch (level) {
      case 'high':
        return const Color(0xFFC1121F);
      case 'medium':
        return const Color(0xFFD4A017);
      default:
        return CropDocColors.safe;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AdvisoryData {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color bgColor;

  const _AdvisoryData({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.bgColor,
  });
}
