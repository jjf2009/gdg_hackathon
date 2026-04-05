class ScanRecord {
  final DateTime date;
  final String cropName;
  final String diseaseName;
  final String status; // 'resolved', 'active', 'monitoring'
  final double confidence;
  final String imagePath;
  final String? treatmentApplied;

  const ScanRecord({
    required this.date,
    required this.cropName,
    required this.diseaseName,
    required this.status,
    required this.confidence,
    required this.imagePath,
    this.treatmentApplied,
  });
}
