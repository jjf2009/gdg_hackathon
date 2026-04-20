import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../services/segmentation_service.dart';

/// Widget that shows the scanned leaf image with a toggleable
/// disease-affected-area mask overlay.
class MaskOverlay extends StatefulWidget {
  final String imagePath;

  const MaskOverlay({super.key, required this.imagePath});

  @override
  State<MaskOverlay> createState() => _MaskOverlayState();
}

class _MaskOverlayState extends State<MaskOverlay> {
  bool _showMask = true;
  bool _isLoading = true;
  SegmentationResult? _result;
  Uint8List? _maskPng;

  @override
  void initState() {
    super.initState();
    _runSegmentation();
  }

  Future<void> _runSegmentation() async {
    final service = SegmentationService.instance;
    if (!service.isAvailable) {
      await service.load();
    }
    if (!service.isAvailable) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final result = await service.segment(widget.imagePath);
    if (result != null) {
      final png = await SegmentationService.maskToPng(result.maskImage);
      if (mounted) {
        setState(() {
          _result = result;
          _maskPng = png;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_result == null || _maskPng == null) {
      return const SizedBox.shrink(); // Nothing to show
    }

    return Container(
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.layers_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(context, 'disease_map_title'),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CropDocColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_result!.affectedPercentage.toStringAsFixed(1)}% ${t(context, 'area_affected')}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: CropDocColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle button
                GestureDetector(
                  onTap: () => setState(() => _showMask = !_showMask),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showMask
                          ? CropDocColors.danger.withValues(alpha: 0.1)
                          : CropDocColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showMask
                            ? CropDocColors.danger.withValues(alpha: 0.3)
                            : CropDocColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showMask ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 14,
                          color: _showMask ? CropDocColors.danger : CropDocColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showMask ? t(context, 'hide_mask') : t(context, 'show_mask'),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _showMask ? CropDocColors.danger : CropDocColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Image with mask overlay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _result!.originalWidth / _result!.originalHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Original image
                    _buildOriginalImage(),

                    // Mask overlay
                    AnimatedOpacity(
                      opacity: _showMask ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Image.memory(
                        _maskPng!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Severity bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _buildSeverityBar(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, duration: 400.ms);
  }

  Widget _buildOriginalImage() {
    final isFile = widget.imagePath.startsWith('/');
    if (isFile) {
      return Image.file(
        File(widget.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.asset(
      widget.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
    color: CropDocColors.primary.withValues(alpha: 0.1),
    child: const Center(
      child: Icon(Icons.broken_image_rounded, size: 40, color: CropDocColors.textMuted),
    ),
  );

  Widget _buildSeverityBar() {
    final pct = _result!.affectedPercentage;
    final severity = pct > 40 ? 'high' : (pct > 15 ? 'medium' : 'low');
    final color = severity == 'high'
        ? CropDocColors.danger
        : severity == 'medium'
            ? CropDocColors.warning
            : CropDocColors.safe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t(context, 'severity_level'),
              style: GoogleFonts.outfit(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: CropDocColors.textMuted,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                severity.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: CropDocColors.divider,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(CropDocColors.primary.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t(context, 'analyzing_affected_area'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CropDocColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: CropDocColors.primary.withValues(alpha: 0.06));
  }
}
