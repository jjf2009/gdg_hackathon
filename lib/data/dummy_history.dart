import '../models/scan_record.dart';

class DummyHistory {
  DummyHistory._();

  static List<ScanRecord> records = [
    // === Rabi season (Dec–May) ===
    ScanRecord(
      date: DateTime(2026, 4, 5),
      cropName: 'Tomato',
      diseaseName: 'Early Blight',
      status: 'active',
      confidence: 0.87,
      imagePath: 'assets/images/early_blight_leaf.png',
    ),
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

    // === Kharif season (Jun–Nov) ===
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

  static int get totalScans => records.length;
  static int get diseasesFound =>
      records.where((r) => r.diseaseName != 'Healthy').length;
  static int get resolvedCount =>
      records.where((r) => r.status == 'resolved').length;
  static int get resolvedPercent =>
      ((resolvedCount / totalScans) * 100).round();
}
