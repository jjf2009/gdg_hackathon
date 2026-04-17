import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/community_alert.dart';

/// Custom-painted mini map showing disease report dots
class DiseaseMap extends StatelessWidget {
  final List<CommunityAlert> alerts;
  const DiseaseMap({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Grid lines to simulate a map
            CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _MapGridPainter(),
            ),
            // "Your field" marker
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 36,
              top: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CropDocColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: CropDocColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      t(context, 'your_field'),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Alert dots
            ...alerts.map((a) => Positioned(
                  left: a.mapX * (MediaQuery.of(context).size.width - 40),
                  top: a.mapY * 180,
                  child: _AlertDot(alert: a),
                )),
            // Legend
            Positioned(
              bottom: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '5 km ${t(context, 'radius')}',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: CropDocColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertDot extends StatefulWidget {
  final CommunityAlert alert;
  const _AlertDot({required this.alert});

  @override
  State<_AlertDot> createState() => _AlertDotState();
}

class _AlertDotState extends State<_AlertDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCDFC6)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Some abstract "field" rectangles
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
