class Disease {
  final String name;
  final String scientificName;
  final double confidence;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String description;
  final String spreadInfo;
  final String urgency;
  final String imagePath;
  final String cropName;

  const Disease({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.spreadInfo,
    required this.urgency,
    required this.imagePath,
    required this.cropName,
  });
}
