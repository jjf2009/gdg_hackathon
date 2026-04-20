import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/app_language.dart';
import '../data/dummy_weather.dart';
import '../widgets/common/weather_banner.dart';
import '../widgets/scan/scan_button.dart';
import '../widgets/scan/scan_overlay.dart';
import '../services/scan_history_service.dart';
import '../services/model_service.dart';
import '../models/scan_record.dart';
import '../models/farm_log.dart';
import '../services/farm_log_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onScanComplete;

  const HomeScreen({super.key, required this.onScanComplete});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _scanning = false;
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  String _selectedAction = 'Fertilizer';
  final List<String> _actionOptions = ['Fertilizer', 'Irrigation', 'Pruning', 'Pesticide'];

  String _selectedCrop = 'Tomato';
  final List<String> _cropOptions = ['Tomato', 'Potato', 'Wheat', 'Corn', 'Cotton'];

  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _startScan() {
    HapticFeedback.mediumImpact();
    _pickImage(ImageSource.camera);
  }

  void _pickFromGallery() {
    HapticFeedback.lightImpact();
    _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (mounted) {
        _pickedImagePath = image?.path;
        setState(() => _scanning = true);
      }
    } catch (e) {
      // If camera/gallery fails, still demo the scan
      if (mounted) {
        _pickedImagePath = null;
        setState(() => _scanning = true);
      }
    }
  }

  Future<void> _onScanDone() async {
    // Run model if image was picked and model is loaded
    ModelPrediction prediction;
    if (_pickedImagePath != null && ModelService.isAvailable) {
      prediction = await ModelService.predict(_pickedImagePath!);
    } else {
      // Fallback demo prediction
      prediction = const ModelPrediction(
        rawLabel: 'Tomato___Early_blight',
        cropName: 'Tomato',
        diseaseName: 'Early Blight',
        confidence: 0.87,
      );
    }

    // Save to history
    ScanHistoryService.instance.addScan(ScanRecord(
      date: DateTime.now(),
      cropName: prediction.cropName,
      diseaseName: prediction.diseaseName,
      status: prediction.isHealthy ? 'resolved' : 'active',
      confidence: prediction.confidence,
      imagePath: _pickedImagePath ?? 'assets/images/early_blight_leaf.png',
    ));

    // Store latest prediction globally so Result screen can read it
    ScanHistoryService.instance.lastPrediction = prediction;

    setState(() => _scanning = false);
    widget.onScanComplete();
  }

  Widget _buildQuickFarmLogCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CropDocColors.safeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_document, color: CropDocColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t(context, 'home_log_action'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: CropDocColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            t(context, 'home_target_crop'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CropDocColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _cropOptions.map((String option) {
                final isSelected = _selectedCrop == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : CropDocColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: CropDocColors.primary,
                    backgroundColor: CropDocColors.surface,
                    side: BorderSide(
                      color: isSelected ? CropDocColors.primary : CropDocColors.divider,
                      width: 1.5,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedCrop = option;
                        });
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t(context, 'home_action_type'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CropDocColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _actionOptions.map((String option) {
                final isSelected = _selectedAction == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : CropDocColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: CropDocColors.primary,
                    backgroundColor: CropDocColors.surface,
                    side: BorderSide(
                      color: isSelected ? CropDocColors.primary : CropDocColors.divider,
                      width: 1.5,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedAction = option;
                        });
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t(context, 'home_quick_note'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CropDocColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: CropDocColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CropDocColors.divider),
            ),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: t(context, 'home_note_hint'),
                hintStyle: const TextStyle(fontSize: 15, color: CropDocColors.textMuted),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.notes, color: CropDocColors.textMuted, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              style: const TextStyle(fontSize: 15, color: CropDocColors.textPrimary),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                FarmLogService.instance.addLog(
                  FarmLog(
                    date: DateTime.now(),
                    actionType: _selectedAction,
                    cropName: _selectedCrop,
                    note: _noteController.text,
                  ),
                );
                _noteController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t(context, 'home_log_saved')),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CropDocColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                t(context, 'home_save_log'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticScanArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t(context, 'home_diagnostic_scan'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: CropDocColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CropDocColors.divider, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: CropDocColors.primaryDark.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: CropDocColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_library_outlined, color: CropDocColors.primary, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'home_gallery'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CropDocColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _startScan,
                child: Container(
                  height: 104,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CropDocColors.primaryLight, CropDocColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: CropDocColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'home_take_photo'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = DummyWeather.current;

    return Stack(
      children: [
        // Clean background matching overall theme
        Container(
          color: CropDocColors.background,
        ),

        // Scrollable Content
        SafeArea(
          child: Column(
            children: [
              // Keep top fixed banner natively out of the scrollable body so it's always at the top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: WeatherBanner(
                  icon: weather.icon,
                  message: t(context, 'weather_msg'),
                  riskLevel: weather.riskLevel,
                ).animate().slideY(
                      begin: -0.3,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).fadeIn(duration: 400.ms),
              ),
              
              // Scrollable body to prevent 'Bottom Overflowed' during interactions
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildQuickFarmLogCard().animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                      const SizedBox(height: 28),
                      _buildDiagnosticScanArea().animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanning overlay
        if (_scanning)
          Positioned.fill(
            child: ScanOverlay(onComplete: _onScanDone),
          ),
      ],
    );
  }
}
