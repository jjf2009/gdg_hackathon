import 'package:flutter/material.dart';

class ScanOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ScanOverlay({super.key, required this.onComplete});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _fadeController;
  late Animation<double> _linePosition;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _linePosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _lineController.forward().then((_) {
      _lineController.reverse().then((_) {
        _fadeController.reverse().then((_) {
          widget.onComplete();
        });
      });
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeOpacity.value,
          child: Stack(
            children: [
              // Dark tinted overlay
              Container(
                color: const Color(0xFF1B4332).withValues(alpha: 0.4),
              ),

              // Corner brackets
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 180),
                  child: CustomPaint(
                    painter: _CornerBracketPainter(),
                  ),
                ),
              ),

              // Moving scan line
              AnimatedBuilder(
                animation: _linePosition,
                builder: (context, child) {
                  return Positioned(
                    top: 180 +
                        (_linePosition.value *
                            (MediaQuery.of(context).size.height - 360)),
                    left: 40,
                    right: 40,
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF52B788).withValues(alpha: 0.9),
                            const Color(0xFF52B788),
                            const Color(0xFF52B788).withValues(alpha: 0.9),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF52B788).withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Center text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Color(0xFF52B788),
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing leaf...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF52B788).withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;

    // Top-left
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - len),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - len, size.height),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
