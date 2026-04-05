import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../data/dummy_weather.dart';
import '../widgets/common/weather_banner.dart';
import '../widgets/scan/scan_button.dart';
import '../widgets/scan/scan_overlay.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onScanComplete;

  const HomeScreen({super.key, required this.onScanComplete});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _scanning = false;

  void _startScan() {
    HapticFeedback.mediumImpact();
    setState(() => _scanning = true);
  }

  void _onScanDone() {
    setState(() => _scanning = false);
    widget.onScanComplete();
  }

  @override
  Widget build(BuildContext context) {
    final weather = DummyWeather.current;

    return Stack(
      children: [
        // Camera viewfinder background
        Positioned.fill(
          child: Image.asset(
            'assets/images/crop_field_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: CropDocColors.darkSurface,
            ),
          ),
        ),

        // Dark overlay to simulate camera viewfinder
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1B1B1B).withValues(alpha: 0.55),
                  const Color(0xFF1B1B1B).withValues(alpha: 0.25),
                  const Color(0xFF1B1B1B).withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Column(
            children: [
              // Weather banner
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: WeatherBanner(
                  icon: weather.icon,
                  message: weather.riskMessage,
                  riskLevel: weather.riskLevel,
                ).animate().slideY(
                      begin: -0.3,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).fadeIn(duration: 400.ms),
              ),

              const Spacer(),

              // Center crosshair area
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _ViewfinderPainter(),
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 0.97,
                    end: 1.0,
                    duration: 2200.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 20),

              // Hint text
              Text(
                'Point at the affected leaf',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const Spacer(),

              // Scan button
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ScanButton(onTap: _startScan),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    delay: 200.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        ),

        // Scanning overlay
        if (_scanning)
          Positioned.fill(
            child: ScanOverlay(onComplete: _onScanDone),
          ),
      ],
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 32.0;

    // Top-left
    canvas.drawLine(const Offset(0, corner), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(corner, 0), paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - corner, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, corner), paint);

    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height - corner), Offset(0, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(corner, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - corner),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - corner, size.height),
        Offset(size.width, size.height), paint);

    // Center cross (subtle)
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx + 12, cy), centerPaint);
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 12), centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
