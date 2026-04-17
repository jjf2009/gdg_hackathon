import 'package:flutter/material.dart';

class CommunityAlert {
  final String farmerName;
  final String villageName;
  final String diseaseName;
  final String cropName;
  final double distanceKm;
  final DateTime reportedAt;
  final double mapX; // 0-1 position on mini map
  final double mapY;
  final Color severity;

  const CommunityAlert({
    required this.farmerName,
    required this.villageName,
    required this.diseaseName,
    required this.cropName,
    required this.distanceKm,
    required this.reportedAt,
    required this.mapX,
    required this.mapY,
    required this.severity,
  });
}

class DiseaseTrend {
  final String diseaseName;
  final int reportsThisWeek;
  final int changePercent; // +40 means 40% increase
  final IconData icon;

  const DiseaseTrend({
    required this.diseaseName,
    required this.reportsThisWeek,
    required this.changePercent,
    required this.icon,
  });
}
