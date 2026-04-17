import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import '../../models/treatment.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  Future<void> _openDirections() async {
    // Free — opens Google Maps app with search query
    final query = Uri.encodeComponent('${shop.name}, ${shop.address}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callShop() async {
    final url = Uri.parse('tel:${shop.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CropDocColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CropDocColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: CropDocColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name + distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: CropDocColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.storefront_rounded, color: CropDocColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(shop.address, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CropDocColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_rounded, size: 13, color: CropDocColors.primary),
                    const SizedBox(width: 4),
                    Text('${shop.distanceKm} km',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: CropDocColors.primary)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Products
          ...shop.products.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    p.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 16,
                    color: p.inStock ? CropDocColors.safe : CropDocColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${p.name} (${p.quantity})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: p.inStock ? CropDocColors.textPrimary : CropDocColors.textMuted,
                        decoration: p.inStock ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  Text('₹${p.priceRupees}',
                    style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: p.inStock ? CropDocColors.textPrimary : CropDocColors.textMuted)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Action buttons — Directions + Call
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: Text(t(context, 'get_directions')),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                child: OutlinedButton(
                  onPressed: _callShop,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: CropDocColors.safe, width: 1.5),
                  ),
                  child: const Icon(Icons.call_rounded, size: 18, color: CropDocColors.safe),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
