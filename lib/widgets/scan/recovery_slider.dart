import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

class RecoverySlider extends StatefulWidget {
  final String beforeImage; // Can be file path (starts with /) or asset path
  final String afterImage;
  const RecoverySlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
  });

  @override
  State<RecoverySlider> createState() => _RecoverySliderState();
}

class _RecoverySliderState extends State<RecoverySlider> {
  double _sliderPosition = 0.5;

  Widget _buildImage(String path, {required BoxFit fit, double? width, double? height, bool isAfter = false}) {
    if (path.startsWith('/')) {
      return Image.file(File(path), fit: fit, width: width, height: height,
        errorBuilder: (_, __, ___) => _fallback(isAfter));
    }
    return Image.asset(path, fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => _fallback(isAfter));
  }

  Widget _fallback(bool isAfter) => Container(
    color: (isAfter ? CropDocColors.safe : CropDocColors.danger).withValues(alpha: 0.2),
    child: Center(child: Icon(
      isAfter ? Icons.eco_rounded : Icons.pest_control_rounded,
      size: 48, color: isAfter ? CropDocColors.safe : CropDocColors.danger,
    )),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_rounded, size: 18, color: CropDocColors.primary),
              const SizedBox(width: 8),
              Text(t(context, 'track_recovery'), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sliderPosition = (details.localPosition.dx / constraints.maxWidth).clamp(0.05, 0.95);
                      });
                    },
                    child: Stack(
                      children: [
                        // After (healthy) — full background
                        Positioned.fill(
                          child: _buildImage(widget.afterImage, fit: BoxFit.cover, isAfter: true),
                        ),
                        // Before (diseased) — clipped
                        ClipRect(
                          clipper: _HalfClipper(fraction: _sliderPosition),
                          child: _buildImage(widget.beforeImage, fit: BoxFit.cover,
                            width: constraints.maxWidth, height: 200),
                        ),
                        // Divider
                        Positioned(
                          left: constraints.maxWidth * _sliderPosition - 1.5,
                          top: 0, bottom: 0,
                          child: Container(
                            width: 3, color: Colors.white,
                            child: Center(
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
                                ),
                                child: const Icon(Icons.drag_indicator_rounded, size: 16, color: CropDocColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                        Positioned(left: 10, bottom: 10,
                          child: _Label(text: t(context, 'before'), color: CropDocColors.danger)),
                        Positioned(right: 10, bottom: 10,
                          child: _Label(text: t(context, 'after'), color: CropDocColors.safe)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(t(context, 'drag_to_compare'),
            style: GoogleFonts.outfit(fontSize: 12, color: CropDocColors.textMuted),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final double fraction;
  _HalfClipper({required this.fraction});
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  @override
  bool shouldReclip(_HalfClipper oldClipper) => oldClipper.fraction != fraction;
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}
