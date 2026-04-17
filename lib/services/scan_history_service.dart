import '../models/scan_record.dart';

/// Global scan history — shared across the app.
/// When a real model is connected, the scan flow writes results here.
class ScanHistoryService {
  ScanHistoryService._();
  static final ScanHistoryService instance = ScanHistoryService._();

  final List<ScanRecord> _records = [
    // Seed with some past records for demo
    ScanRecord(
      date: DateTime(2026, 3, 28),
      cropName: 'Tomato',
      diseaseName: 'Healthy',
      status: 'resolved',
      confidence: 0.95,
      imagePath: 'assets/images/healthy_leaf.png',
    ),
    ScanRecord(
      date: DateTime(2026, 3, 15),
      cropName: 'Onion',
      diseaseName: 'Powdery Mildew',
      status: 'resolved',
      confidence: 0.79,
      imagePath: 'assets/images/healthy_leaf.png',
      treatmentApplied: 'Sulphur spray',
    ),
    ScanRecord(
      date: DateTime(2026, 2, 22),
      cropName: 'Tomato',
      diseaseName: 'Late Blight',
      status: 'resolved',
      confidence: 0.92,
      imagePath: 'assets/images/early_blight_leaf.png',
      treatmentApplied: 'Metalaxyl + Mancozeb',
    ),
    ScanRecord(
      date: DateTime(2026, 1, 18),
      cropName: 'Cotton',
      diseaseName: 'Bacterial Blight',
      status: 'resolved',
      confidence: 0.84,
      imagePath: 'assets/images/early_blight_leaf.png',
      treatmentApplied: 'Copper oxychloride',
    ),
    // Kharif season
    ScanRecord(
      date: DateTime(2025, 10, 12),
      cropName: 'Soybean',
      diseaseName: 'Bacterial Blight',
      status: 'resolved',
      confidence: 0.81,
      imagePath: 'assets/images/early_blight_leaf.png',
      treatmentApplied: 'Streptomycin sulphate',
    ),
    ScanRecord(
      date: DateTime(2025, 9, 5),
      cropName: 'Cotton',
      diseaseName: 'Healthy',
      status: 'resolved',
      confidence: 0.96,
      imagePath: 'assets/images/healthy_leaf.png',
    ),
    ScanRecord(
      date: DateTime(2025, 8, 18),
      cropName: 'Soybean',
      diseaseName: 'Powdery Mildew',
      status: 'resolved',
      confidence: 0.73,
      imagePath: 'assets/images/healthy_leaf.png',
      treatmentApplied: 'Wettable sulphur',
    ),
    ScanRecord(
      date: DateTime(2025, 7, 2),
      cropName: 'Cotton',
      diseaseName: 'Early Blight',
      status: 'resolved',
      confidence: 0.88,
      imagePath: 'assets/images/early_blight_leaf.png',
      treatmentApplied: 'Mancozeb spray',
    ),
  ];

  List<ScanRecord> get records => List.unmodifiable(_records);

  /// Called after a scan completes — adds the result to history.
  /// When connecting the real model, call this with the actual prediction.
  void addScan(ScanRecord record) {
    _records.insert(0, record); // newest first
  }

  /// Called when a treatment is applied to the latest active scan.
  void markTreated(String treatmentName) {
    final idx = _records.indexWhere((r) => r.status == 'active');
    if (idx != -1) {
      final old = _records[idx];
      _records[idx] = ScanRecord(
        date: old.date,
        cropName: old.cropName,
        diseaseName: old.diseaseName,
        status: 'resolved',
        confidence: old.confidence,
        imagePath: old.imagePath,
        treatmentApplied: treatmentName,
      );
    }
  }
}
