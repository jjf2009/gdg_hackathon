import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
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

  void _goToTab(int index) {
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTab == 0
          ? CropDocColors.darkSurface
          : CropDocColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _buildScreen(),
      ),
      bottomNavigationBar: BottomNavBar(
              currentIndex: _currentTab,
              onTap: _goToTab,
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
