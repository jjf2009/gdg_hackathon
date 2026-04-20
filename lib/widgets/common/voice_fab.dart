import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

/// Floating Action Button for push-to-talk voice interaction.
/// Shows animated pulse ring when listening.
class VoiceFab extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final VoidCallback onPressed;

  const VoiceFab({
    super.key,
    required this.isListening,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring animation when listening
          if (isListening)
            ..._buildPulseRings(),

          // Main FAB button
          GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isListening
                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                      : [CropDocColors.primary, const Color(0xFF15803D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isListening
                            ? const Color(0xFFEF4444)
                            : CropDocColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: isListening ? 20 : 12,
                    spreadRadius: isListening ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isListening ? Icons.mic : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPulseRings() {
    return [
      _PulseRing(delay: 0),
      _PulseRing(delay: 400),
      _PulseRing(delay: 800),
    ];
  }
}

class _PulseRing extends StatelessWidget {
  final int delay;
  const _PulseRing({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    )
        .animate(
          onPlay: (c) => c.repeat(),
        )
        .scaleXY(
          begin: 1.0,
          end: 1.8,
          duration: 1200.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOut,
        )
        .fadeOut(
          duration: 1200.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeOut,
        );
  }
}
