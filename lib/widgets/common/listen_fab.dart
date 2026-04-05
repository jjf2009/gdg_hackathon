import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ListenFab extends StatefulWidget {
  const ListenFab({super.key});

  @override
  State<ListenFab> createState() => _ListenFabState();
}

class _ListenFabState extends State<ListenFab>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _pulseController.repeat(reverse: true);
        // Auto stop after 4 seconds (simulated)
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _isPlaying) {
            setState(() {
              _isPlaying = false;
              _pulseController.stop();
              _pulseController.reset();
            });
          }
        });
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
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
            _isPlaying
                ? Icons.volume_up_rounded
                : Icons.volume_up_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
