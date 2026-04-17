import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

class ListenFab extends StatefulWidget {
  final String speechText;

  const ListenFab({super.key, required this.speechText});

  @override
  State<ListenFab> createState() => _ListenFabState();
}

class _ListenFabState extends State<ListenFab>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _pulseController.stop();
          _pulseController.reset();
        });
      }
    });

    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
        _pulseController.stop();
        _pulseController.reset();
      });
    } else {
      final lang = LanguageScope.of(context)?.language ?? 'en';
      final ttsLocale = supportedLanguages
          .firstWhere((l) => l.code == lang,
              orElse: () => supportedLanguages.first)
          .ttsLocale;

      await _tts.setLanguage(ttsLocale);
      setState(() {
        _isPlaying = true;
        _pulseController.repeat(reverse: true);
      });
      await _tts.speak(widget.speechText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPlaying ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _isPlaying ? CropDocColors.primary : CropDocColors.secondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_isPlaying
                        ? CropDocColors.primary
                        : CropDocColors.secondary)
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
