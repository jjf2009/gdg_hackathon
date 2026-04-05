import '../models/treatment.dart';

class DummyTreatments {
  DummyTreatments._();

  static const List<TreatmentStep> earlyBlightSteps = [
    TreatmentStep(
      icon: '🧴',
      instruction: 'Spray Mancozeb solution before sunset today',
      urgencyLabel: 'Do today',
      detail: 'Mix 2.5g per litre of water. Spray on all leaves, top and bottom.',
    ),
    TreatmentStep(
      icon: '✂️',
      instruction: 'Remove the 3-4 most affected leaves',
      urgencyLabel: 'Do today',
      detail: 'Cut them off and take them away from the field. Don\'t leave them on the ground.',
    ),
    TreatmentStep(
      icon: '💧',
      instruction: 'Water at the base only — avoid wetting leaves',
      urgencyLabel: 'Ongoing',
      detail: 'Use drip irrigation or pour water directly at the roots. Wet leaves help the fungus grow.',
    ),
  ];

  static const List<Shop> nearbyShops = [
    Shop(
      name: 'Patil Krushi Kendra',
      distanceKm: 2.3,
      address: 'Near Bus Stand, Baramati',
      phoneNumber: '9876543210',
      products: [
        Product(
          name: 'Mancozeb 75% WP',
          quantity: '500g',
          priceRupees: 180,
        ),
        Product(
          name: 'Chlorothalonil',
          quantity: '250ml',
          priceRupees: 320,
        ),
      ],
    ),
    Shop(
      name: 'Sharma Agri Store',
      distanceKm: 4.1,
      address: 'Main Road, Indapur',
      phoneNumber: '9123456789',
      products: [
        Product(
          name: 'Mancozeb 75% WP',
          quantity: '500g',
          priceRupees: 175,
        ),
        Product(
          name: 'Neem Oil (organic)',
          quantity: '500ml',
          priceRupees: 220,
        ),
      ],
    ),
    Shop(
      name: 'Mauli Agro Services',
      distanceKm: 6.8,
      address: 'Pune-Solapur Highway, Daund',
      phoneNumber: '9988776655',
      products: [
        Product(
          name: 'Mancozeb 75% WP',
          quantity: '1kg',
          priceRupees: 310,
        ),
        Product(
          name: 'Trichoderma viride',
          quantity: '1kg',
          priceRupees: 280,
          inStock: false,
        ),
      ],
    ),
  ];
}
