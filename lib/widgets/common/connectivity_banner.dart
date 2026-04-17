import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  // States: 'online', 'offline', 'syncing'
  String _status = 'online';
  Timer? _timer;
  int _savedScans = 0;

  @override
  void initState() {
    super.initState();
    // Simulate connectivity changes for demo
    _timer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() { _status = 'offline'; _savedScans = 1; });
      // Go back online after a while
      _timer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _status = 'syncing');
        _timer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() { _status = 'online'; _savedScans = 0; });
          // Cycle again
          _timer = Timer(const Duration(seconds: 15), () {
            if (mounted) setState(() { _status = 'offline'; _savedScans = 2; });
            _timer = Timer(const Duration(seconds: 7), () {
              if (mounted) setState(() => _status = 'syncing');
              _timer = Timer(const Duration(seconds: 3), () {
                if (mounted) setState(() { _status = 'online'; _savedScans = 0; });
              });
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == 'online' && _savedScans == 0) return const SizedBox.shrink();

    Color bgColor;
    IconData icon;
    String message;

    switch (_status) {
      case 'offline':
        bgColor = const Color(0xFF4A4A4A);
        icon = Icons.cloud_off_rounded;
        message = '${t(context, 'offline_mode')} — $_savedScans ${t(context, 'scans_saved')}';
        break;
      case 'syncing':
        bgColor = CropDocColors.primary;
        icon = Icons.cloud_sync_rounded;
        message = t(context, 'syncing_scans');
        break;
      default:
        bgColor = CropDocColors.safe;
        icon = Icons.cloud_done_rounded;
        message = t(context, 'back_online');
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _status == 'syncing'
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
