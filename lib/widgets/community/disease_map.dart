import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/community_alert.dart';

/// Data-driven disease radius map. Dot positions, sizes, and pulse rates
/// derive from actual alert data (distance, severity, recency).
class DiseaseMap extends StatelessWidget {
  final List<CommunityAlert> alerts;
  const DiseaseMap({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final diseaseAlerts = alerts.where((a) => a.diseaseName != 'Healthy').toList();
    final maxDistance = diseaseAlerts.isEmpty ? 5.0
        : diseaseAlerts.map((a) => a.distanceKm).reduce(max).clamp(1.0, 20.0);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final centerX = w / 2;
            final centerY = h * 0.42;

            return Stack(
              children: [
                // Grid
                CustomPaint(
                  size: Size(w, h),
                  painter: _MapGridPainter(),
                ),
                // Distance rings (data-driven radii)
                ..._buildRadiusRings(centerX, centerY, w, maxDistance),

                // Your field marker
                Positioned(
                  left: centerX - 36,
                  top: centerY - 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CropDocColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: CropDocColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8, spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(t(context, 'your_field'),
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                // Alert dots — positioned by distance and angle
                ...diseaseAlerts.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  final fraction = (a.distanceKm / maxDistance).clamp(0.1, 0.9);
                  // Spread dots in a circle from center
                  final angle = (i * 137.5) * pi / 180; // golden angle for nice spread
                  final radius = fraction * min(w, h) * 0.4;
                  final dotX = centerX + radius * cos(angle) - 8;
                  final dotY = centerY + radius * sin(angle) - 8;

                  return Positioned(
                    left: dotX.clamp(4, w - 20),
                    top: dotY.clamp(4, h - 20),
                    child: _AlertDot(alert: a),
                  );
                }),

                // Stats overlay
                Positioned(
                  top: 8, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${diseaseAlerts.length} ${t(context, 'reports_nearby')}',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600,
                        color: diseaseAlerts.isNotEmpty ? CropDocColors.danger : CropDocColors.safe),
                    ),
                  ),
                ),

                // Radius legend
                Positioned(
                  bottom: 8, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${maxDistance.toStringAsFixed(0)} km ${t(context, 'radius')}',
                      style: GoogleFonts.outfit(fontSize: 10, color: CropDocColors.textMuted),
                    ),
                  ),
                ),

                // Tap hint
                Positioned(
                  bottom: 8, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 10, color: CropDocColors.textMuted),
                        const SizedBox(width: 3),
                        Text('Tap dots for info',
                          style: GoogleFonts.outfit(fontSize: 9, color: CropDocColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildRadiusRings(double cx, double cy, double mapWidth, double maxDist) {
    // Draw 2-3 concentric rings representing distance
    final rings = <Widget>[];
    final distances = [maxDist * 0.33, maxDist * 0.66, maxDist];
    for (final d in distances) {
      final r = (d / maxDist) * min(mapWidth, 220.0) * 0.4;
      rings.add(Positioned(
        left: cx - r,
        top: cy - r,
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CropDocColors.textMuted.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
      ));
    }
    return rings;
  }
}

class _AlertDot extends StatefulWidget {
  final CommunityAlert alert;
  const _AlertDot({required this.alert});

  @override
  State<_AlertDot> createState() => _AlertDotState();
}

class _AlertDotState extends State<_AlertDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Recent alerts pulse faster
    final recency = DateTime.now().difference(widget.alert.reportedAt).inHours;
    final duration = recency < 6 ? 800 : recency < 24 ? 1500 : 2500;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${widget.alert.diseaseName} on ${widget.alert.cropName} — ${widget.alert.farmerName}, ${widget.alert.villageName} (${widget.alert.distanceKm} km)'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ));
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 16 + (_controller.value * 4),
            height: 16 + (_controller.value * 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.alert.severity.withValues(alpha: 0.7),
              boxShadow: [
                BoxShadow(
                  color: widget.alert.severity.withValues(alpha: 0.3 + _controller.value * 0.2),
                  blurRadius: 6 + _controller.value * 4,
                  spreadRadius: _controller.value * 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCDFC6)
      ..strokeWidth = 0.5;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final fieldPaint = Paint()
      ..color = const Color(0xFFD4E8CD)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.15, size.width * 0.25, size.height * 0.3),
        const Radius.circular(4)),
      fieldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.4, size.width * 0.3, size.height * 0.25),
        const Radius.circular(4)),
      fieldPaint..color = const Color(0xFFBDDAB3),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.6, size.width * 0.2, size.height * 0.2),
        const Radius.circular(4)),
      fieldPaint..color = const Color(0xFFD4E8CD),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
