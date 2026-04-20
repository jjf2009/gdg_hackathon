import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

/// Bottom overlay that shows during voice interaction.
/// Displays listening state, recognized text, and detected intent feedback.
class VoiceOverlay extends StatelessWidget {
  final bool isVisible;
  final bool isListening;
  final bool isProcessing;
  final String partialText;
  final String? resultText;
  final String? intentFeedback;
  final String? errorText;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;
  final String language;

  const VoiceOverlay({
    super.key,
    required this.isVisible,
    required this.isListening,
    required this.isProcessing,
    required this.partialText,
    this.resultText,
    this.intentFeedback,
    this.errorText,
    required this.onDismiss,
    required this.onRetry,
    this.language = 'hi',
  });

  String _getListeningLabel(BuildContext context) {
    return t(context, 'voice_listening');
  }

  String _getProcessingLabel(BuildContext context) {
    return t(context, 'voice_processing');
  }

  String _getTapToSpeakLabel(BuildContext context) {
    return t(context, 'voice_tap_to_speak');
  }

  String _getFollowUpPrompt(BuildContext context) {
    // Return contextual follow-up prompts based on state
    if (errorText != null) {
      return t(context, 'voice_followup_scan');
    }
    if (resultText != null) {
      final lower = resultText!.toLowerCase();
      if (lower.contains('treat') || lower.contains('medicine') || lower.contains('spray')) {
        return t(context, 'voice_followup_treatment');
      }
      if (lower.contains('home') || lower.contains('main')) {
        return t(context, 'voice_followup_scan');
      }
      if (lower.contains('history') || lower.contains('scan') || lower.contains('past')) {
        return t(context, 'voice_followup_home');
      }
    }
    // Default: cycle through common commands
    return t(context, 'voice_followup_treatment');
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: CropDocColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CropDocColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Status indicator
                _buildStatusRow(context),
                const SizedBox(height: 12),

                // Recognized text
                if (partialText.isNotEmpty || resultText != null)
                  _buildTextDisplay(),

                // Intent feedback
                if (intentFeedback != null) ...[
                  const SizedBox(height: 12),
                  _buildIntentFeedback(),
                ],

                // Error
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  _buildError(),
                ],

                const SizedBox(height: 16),

                // Action buttons
                _buildActions(context),

                // Follow-up prompt suggestion
                if (resultText != null || errorText != null) ...[
                  const SizedBox(height: 12),
                  _buildFollowUpPrompt(context),
                ],
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    IconData icon;
    String label;
    Color color;

    if (errorText != null) {
      icon = Icons.error_outline_rounded;
      label = errorText!;
      color = const Color(0xFFEF4444);
    } else if (isProcessing) {
      icon = Icons.psychology_rounded;
      label = _getProcessingLabel(context);
      color = const Color(0xFFF59E0B);
    } else if (isListening) {
      icon = Icons.mic_rounded;
      label = _getListeningLabel(context);
      color = const Color(0xFFEF4444);
    } else {
      icon = Icons.mic_none_rounded;
      label = _getTapToSpeakLabel(context);
      color = CropDocColors.primary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (isListening)
          Container(
            margin: const EdgeInsets.only(left: 8),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(
                duration: 600.ms,
              ),
      ],
    );
  }

  Widget _buildTextDisplay() {
    final displayText = resultText ?? partialText;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: resultText != null
              ? CropDocColors.textPrimary
              : CropDocColors.textMuted,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIntentFeedback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CropDocColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CropDocColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: CropDocColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              intentFeedback!,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CropDocColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorText!,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (errorText != null)
          _ActionButton(
            icon: Icons.refresh_rounded,
            label: t(context, 'voice_retry'),
            onTap: onRetry,
            primary: true,
          ),
        _ActionButton(
          icon: Icons.close_rounded,
          label: t(context, 'voice_close'),
          onTap: onDismiss,
          primary: false,
        ),
      ],
    );
  }

  Widget _buildFollowUpPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CropDocColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CropDocColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: CropDocColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFollowUpPrompt(context),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CropDocColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: primary ? CropDocColors.primary : CropDocColors.textMuted,
          backgroundColor: primary
              ? CropDocColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
