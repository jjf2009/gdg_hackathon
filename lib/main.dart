import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';
import 'config/app_language.dart';
import 'screens/home_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/treatment_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/layout/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );
  runApp(const CropDocApp());
}

class CropDocApp extends StatelessWidget {
  const CropDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropDoc',
      debugShowCheckedModeBanner: false,
      theme: CropDocTheme.lightTheme,
      home: const CropDocShell(),
    );
  }
}

class CropDocShell extends StatefulWidget {
  const CropDocShell({super.key});

  @override
  State<CropDocShell> createState() => _CropDocShellState();
}

class _CropDocShellState extends State<CropDocShell> {
  int _currentTab = 0;
  String _language = 'en';

  void _goToTab(int index) {
    setState(() => _currentTab = index);
  }

  void _setLanguage(String lang) {
    setState(() => _language = lang);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguageSheet(
        currentLang: _language,
        onSelect: (lang) {
          _setLanguage(lang);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      language: _language,
      onLanguageChanged: _setLanguage,
      child: Scaffold(
        backgroundColor: _currentTab == 0
            ? CropDocColors.darkSurface
            : CropDocColors.background,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildScreen(),
            ),
            // Language selector pill — top right
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: GestureDetector(
                onTap: _showLanguagePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _currentTab == 0
                        ? Colors.white.withValues(alpha: 0.15)
                        : CropDocColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _currentTab == 0
                          ? Colors.white.withValues(alpha: 0.3)
                          : CropDocColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 16,
                        color: _currentTab == 0
                            ? Colors.white
                            : CropDocColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _language.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _currentTab == 0
                              ? Colors.white
                              : CropDocColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentTab,
          onTap: _goToTab,
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentTab) {
      case 0:
        return HomeScreen(
          key: const ValueKey('home'),
          onScanComplete: () => _goToTab(1),
        );
      case 1:
        return ScanResultScreen(
          key: const ValueKey('scanResult'),
          onViewTreatment: () => _goToTab(2),
        );
      case 2:
        return const TreatmentScreen(key: ValueKey('treatment'));
      case 3:
        return const HistoryScreen(key: ValueKey('history'));
      default:
        return HomeScreen(
          key: const ValueKey('home'),
          onScanComplete: () => _goToTab(1),
        );
    }
  }
}

class _LanguageSheet extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onSelect;

  const _LanguageSheet({required this.currentLang, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CropDocColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CropDocColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Select Language',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...supportedLanguages.map((lang) {
            final isActive = lang.code == currentLang;
            return GestureDetector(
              onTap: () => onSelect(lang.code),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? CropDocColors.primary.withValues(alpha: 0.08)
                      : CropDocColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? CropDocColors.primary
                        : CropDocColors.divider,
                    width: isActive ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      lang.nativeName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? CropDocColors.primary
                            : CropDocColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      lang.name,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: CropDocColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (isActive)
                      const Icon(Icons.check_circle_rounded,
                          color: CropDocColors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
