import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/community_alert.dart';

class DummyCommunity {
  DummyCommunity._();

  static final List<CommunityAlert> alerts = [
    CommunityAlert(
      farmerName: 'Ramesh Patil',
      villageName: 'Mandavgan',
      diseaseName: 'Early Blight',
      cropName: 'Tomato',
      distanceKm: 1.8,
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      mapX: 0.55, mapY: 0.35,
      severity: CropDocColors.danger,
    ),
    CommunityAlert(
      farmerName: 'Sunita Jadhav',
      villageName: 'Loni Kalbhor',
      diseaseName: 'Early Blight',
      cropName: 'Tomato',
      distanceKm: 3.2,
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
      mapX: 0.3, mapY: 0.55,
      severity: CropDocColors.danger,
    ),
    CommunityAlert(
      farmerName: 'Vijay Shinde',
      villageName: 'Uruli Kanchan',
      diseaseName: 'Powdery Mildew',
      cropName: 'Onion',
      distanceKm: 4.5,
      reportedAt: DateTime.now().subtract(const Duration(hours: 14)),
      mapX: 0.72, mapY: 0.6,
      severity: CropDocColors.warning,
    ),
    CommunityAlert(
      farmerName: 'Anil More',
      villageName: 'Jejuri',
      diseaseName: 'Late Blight',
      cropName: 'Tomato',
      distanceKm: 6.1,
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      mapX: 0.2, mapY: 0.75,
      severity: CropDocColors.danger,
    ),
    CommunityAlert(
      farmerName: 'Priya Kulkarni',
      villageName: 'Saswad',
      diseaseName: 'Healthy',
      cropName: 'Soybean',
      distanceKm: 5.4,
      reportedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      mapX: 0.8, mapY: 0.28,
      severity: CropDocColors.safe,
    ),
  ];

  static final List<DiseaseTrend> trends = [
    const DiseaseTrend(
      diseaseName: 'Early Blight',
      reportsThisWeek: 12,
      changePercent: 40,
      icon: Icons.trending_up_rounded,
    ),
    const DiseaseTrend(
      diseaseName: 'Powdery Mildew',
      reportsThisWeek: 5,
      changePercent: 10,
      icon: Icons.trending_flat_rounded,
    ),
    const DiseaseTrend(
      diseaseName: 'Late Blight',
      reportsThisWeek: 3,
      changePercent: -20,
      icon: Icons.trending_down_rounded,
    ),
  ];

  static int get totalNearbyReports => alerts.where((a) => a.diseaseName != 'Healthy').length;
}
