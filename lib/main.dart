import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'config/app_language.dart';
import 'screens/home_screen.dart';
import 'screens/scan_result_screen.dart';
import 'screens/treatment_screen.dart';
import 'screens/community_screen.dart';
import 'screens/history_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/layout/bottom_nav_bar.dart';
import 'widgets/common/connectivity_banner.dart';
import 'widgets/common/voice_fab.dart';
import 'widgets/common/voice_overlay.dart';
import 'services/model_service.dart';
import 'widgets/finance/advisor_sheet.dart';
import 'services/scan_history_service.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'services/intent_service.dart';
import 'services/groq_service.dart';
import 'services/navigation_service.dart';
import 'services/segmentation_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Could not load .env file: $e');
  }

  // Load TFLite models (fails silently if model files not present)
  await ModelService.load();
  SegmentationService.instance.load(); // async, non-blocking

  // Initialize voice services
  GroqService().initialize();
  await SupabaseService().initialize();

  runApp(const CropDocApp());
}

class CropDocApp extends StatefulWidget {
  const CropDocApp({super.key});

  @override
  State<CropDocApp> createState() => _CropDocAppState();
}

class _CropDocAppState extends State<CropDocApp> {
  bool _showOnboarding = true;
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return MaterialApp(
        title: 'CropDoc',
        debugShowCheckedModeBanner: false,
        theme: CropDocTheme.lightTheme,
        darkTheme: CropDocTheme.darkTheme,
        themeMode: _themeMode,
        home: OnboardingScreen(
          onComplete: () => setState(() => _showOnboarding = false),
        ),
      );
    }
    return MaterialApp(
      title: 'CropDoc',
      debugShowCheckedModeBanner: false,
      theme: CropDocTheme.lightTheme,
      darkTheme: CropDocTheme.darkTheme,
      themeMode: _themeMode,
      home: CropDocShell(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class CropDocShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const CropDocShell({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<CropDocShell> createState() => _CropDocShellState();
}

class _CropDocShellState extends State<CropDocShell> {
  int _currentTab = 0;
  String _language = 'en';

  // Voice state
  bool _isListening = false;
  bool _isProcessing = false;
  bool _showVoiceOverlay = false;
  String _partialText = '';
  String? _resultText;
  String? _intentFeedback;
  String? _errorText;

  // Services
  final SttService _stt = SttService();
  final TtsService _tts = TtsService();
  final IntentService _intentService = IntentService();
  final GroqService _groq = GroqService();
  final NavigationService _navService = NavigationService();

  StreamSubscription? _sttPartialSub;
  StreamSubscription? _sttResultSub;
  StreamSubscription? _sttStateSub;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    _initVoiceServices();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_language');
      if (saved != null && saved.isNotEmpty) {
        setState(() => _language = saved);
      }
    } catch (_) {}
  }

  Future<void> _saveLanguage(String lang) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', lang);
    } catch (_) {}
  }

  Future<void> _initVoiceServices() async {
    await _tts.initialize();
    await _intentService.loadKeywords();
    await _navService.loadVoiceStrings();

    // Wire navigation to tab switching
    _navService.onTabSwitch = (tabIndex) {
      setState(() => _currentTab = tabIndex);
    };

    // Listen to STT events
    _sttPartialSub = _stt.onPartial.listen((partial) {
      if (mounted) {
        setState(() => _partialText = partial);
      }
    });

    _sttResultSub = _stt.onResult.listen((result) {
      if (mounted) {
        _handleSttResult(result);
      }
    });

    _sttStateSub = _stt.onStateChange.listen((state) {
      if (mounted) {
        switch (state) {
          case SttState.noPermission:
            setState(() {
              _errorText = t(context, 'voice_no_mic');
              _isListening = false;
              _isProcessing = false;
            });
            break;
          case SttState.error:
            setState(() {
              _errorText = t(context, 'voice_error');
              _isListening = false;
              _isProcessing = false;
            });
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> _handleSttResult(SttResult result) async {
    setState(() {
      _resultText = result.text;
      _isListening = false;
      _isProcessing = true;
      _partialText = '';
    });

    // Stop listening
    await _stt.stopListening();

    try {
      // Parse intent (tries Groq first, falls back to offline)
      final intent = await _groq.parseIntent(result.text, lang: _language);

      // Execute navigation
      final feedback = await _navService.executeIntent(intent);

      if (mounted) {
        setState(() {
          _intentFeedback = feedback;
          _isProcessing = false;
        });

        // Auto-dismiss after showing feedback
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showVoiceOverlay = false;
              _resultText = null;
              _intentFeedback = null;
              _errorText = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = t(context, 'voice_error');
          _isProcessing = false;
        });
      }
    }
  }

  void _toggleVoice() async {
    if (_isListening) {
      // Stop listening
      await _stt.stopListening();
      setState(() {
        _isListening = false;
        _showVoiceOverlay = false;
      });
    } else {
      // Start listening
      setState(() {
        _showVoiceOverlay = true;
        _partialText = '';
        _resultText = null;
        _intentFeedback = null;
        _errorText = null;
      });

      _navService.setLanguage(_language);
      await _tts.setLanguage(_language);

      final started = await _stt.startListening();
      if (started) {
        setState(() => _isListening = true);
      } else {
        setState(() {
          _errorText = t(context, 'voice_no_mic');
        });
      }
    }
  }

  void _retryVoice() {
    setState(() {
      _errorText = null;
      _resultText = null;
      _intentFeedback = null;
    });
    _toggleVoice();
  }

  void _dismissOverlay() {
    _stt.stopListening();
    setState(() {
      _isListening = false;
      _isProcessing = false;
      _showVoiceOverlay = false;
      _partialText = '';
      _resultText = null;
      _intentFeedback = null;
      _errorText = null;
    });
  }

  void _goToTab(int index) => setState(() => _currentTab = index);
  void _setLanguage(String lang) {
    setState(() => _language = lang);
    _saveLanguage(lang);
    _navService.setLanguage(lang);
    _tts.setLanguage(lang);
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
  void dispose() {
    _sttPartialSub?.cancel();
    _sttResultSub?.cancel();
    _sttStateSub?.cancel();
    _stt.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      language: _language,
      onLanguageChanged: _setLanguage,
      child: Scaffold(
        backgroundColor: CropDocColors.background,
        body: Column(
          children: [
            // Offline/syncing banner
            const ConnectivityBanner(),
            Expanded(
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _buildScreen(),
                  ),
                  // Language selector pill + Dark mode toggle
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Agri-Finance Advisor Button
                        GestureDetector(
                          onTap: () => AdvisorSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: CropDocColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CropDocColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.currency_rupee_rounded, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'FINANCE',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Language picker
                        GestureDetector(
                          onTap: _showLanguagePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CropDocColors.primaryDark.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: CropDocColors.divider, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.translate_rounded, size: 16, color: CropDocColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _language.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w700,
                                    color: CropDocColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Voice overlay
                  VoiceOverlay(
                    isVisible: _showVoiceOverlay,
                    isListening: _isListening,
                    isProcessing: _isProcessing,
                    partialText: _partialText,
                    resultText: _resultText,
                    intentFeedback: _intentFeedback,
                    errorText: _errorText,
                    onDismiss: _dismissOverlay,
                    onRetry: _retryVoice,
                    language: _language,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Voice FAB
        floatingActionButton: VoiceFab(
          isListening: _isListening,
          isProcessing: _isProcessing,
          onPressed: _toggleVoice,
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
        return HomeScreen(key: const ValueKey('home'), onScanComplete: () => _goToTab(1));
      case 1:
        return ScanResultScreen(key: const ValueKey('scanResult'), onViewTreatment: () => _goToTab(2));
      case 2:
        return const TreatmentScreen(key: ValueKey('treatment'));
      case 3:
        return const CommunityScreen(key: ValueKey('community'));
      case 4:
        return const HistoryScreen(key: ValueKey('history'));
      default:
        return HomeScreen(key: const ValueKey('home'), onScanComplete: () => _goToTab(1));
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: CropDocColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Select Language', style: Theme.of(context).textTheme.headlineSmall),
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
                  color: isActive ? CropDocColors.primary.withValues(alpha: 0.08) : CropDocColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? CropDocColors.primary : CropDocColors.divider,
                    width: isActive ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.nativeName,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600,
                        color: isActive ? CropDocColors.primary : CropDocColors.textPrimary)),
                    const SizedBox(width: 10),
                    Text(lang.name, style: GoogleFonts.outfit(fontSize: 14, color: CropDocColors.textMuted)),
                    const Spacer(),
                    if (isActive)
                      const Icon(Icons.check_circle_rounded, color: CropDocColors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      ),
    );
  }
}
