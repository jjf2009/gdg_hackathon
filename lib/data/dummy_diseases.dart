import '../models/disease.dart';

class DummyDiseases {
  DummyDiseases._();

  static const Disease earlyBlight = Disease(
    name: 'Early Blight',
    scientificName: 'Alternaria solani',
    confidence: 0.87,
    severity: 'high',
    description:
        'This fungus makes round brown spots with rings on the leaves. '
        'It starts on the older leaves at the bottom and spreads upward.',
    spreadInfo:
        'Spreads fast in humid weather, especially when leaves stay wet overnight.',
    urgency: 'Act within 24 hours — this spreads quickly in wet conditions.',
    imagePath: 'assets/images/early_blight_leaf.png',
    cropName: 'Tomato',
  );

  static const Disease lateBlight = Disease(
    name: 'Late Blight',
    scientificName: 'Phytophthora infestans',
    confidence: 0.92,
    severity: 'critical',
    description:
        'Dark, water-soaked patches on leaves and stems. '
        'White fuzzy growth may appear underneath in humid mornings.',
    spreadInfo: 'Can destroy an entire field in days during rainy season.',
    urgency: 'Emergency — spray today before sunset.',
    imagePath: 'assets/images/early_blight_leaf.png',
    cropName: 'Tomato',
  );

  static const Disease powderyMildew = Disease(
    name: 'Powdery Mildew',
    scientificName: 'Erysiphe cichoracearum',
    confidence: 0.79,
    severity: 'medium',
    description:
        'White powdery coating on the top of leaves. '
        'Leaves may curl and turn yellow over time.',
    spreadInfo: 'Common in warm, dry days followed by cool, humid nights.',
    urgency: 'Treat within 2-3 days to prevent spread.',
    imagePath: 'assets/images/healthy_leaf.png',
    cropName: 'Onion',
  );

  static const Disease healthy = Disease(
    name: 'Healthy',
    scientificName: '-',
    confidence: 0.95,
    severity: 'low',
    description: 'This leaf looks healthy! No signs of disease spotted.',
    spreadInfo: '',
    urgency: 'No action needed. Keep monitoring weekly.',
    imagePath: 'assets/images/healthy_leaf.png',
    cropName: 'Tomato',
  );

  static const List<Disease> all = [
    earlyBlight,
    lateBlight,
    powderyMildew,
    healthy,
  ];
}
