import 'package:flutter/material.dart';

class TreatmentStep {
  final IconData icon;
  final String instruction;
  final String urgencyLabel;
  final String? detail;

  const TreatmentStep({
    required this.icon,
    required this.instruction,
    required this.urgencyLabel,
    this.detail,
  });
}

class Product {
  final String name;
  final String quantity;
  final int priceRupees;
  final bool inStock;

  const Product({
    required this.name,
    required this.quantity,
    required this.priceRupees,
    this.inStock = true,
  });
}

class Shop {
  final String name;
  final double distanceKm;
  final String address;
  final List<Product> products;
  final String? phoneNumber;

  const Shop({
    required this.name,
    required this.distanceKm,
    required this.address,
    required this.products,
    this.phoneNumber,
  });
}
