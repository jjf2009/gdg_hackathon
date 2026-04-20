import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';

class AdvisorSheet extends StatefulWidget {
  const AdvisorSheet({super.key});

  /// Opens the advisor sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvisorSheet(),
    );
  }

  @override
  State<AdvisorSheet> createState() => _AdvisorSheetState();
}

class _AdvisorSheetState extends State<AdvisorSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: CropDocColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: CropDocColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CropDocColors.primaryLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_rupee_rounded, color: CropDocColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Agri-Finance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CropDocColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: CropDocColors.textSecondary),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CropDocColors.divider),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: CropDocColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CropDocColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: CropDocColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Market Prices'),
                Tab(text: 'Govt Schemes'),
              ],
              onTap: (_) => HapticFeedback.selectionClick(),
            ),
          ),
          const SizedBox(height: 20),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMarketTab().animate().fadeIn().slideX(begin: 0.05),
                _buildSchemesTab().animate().fadeIn().slideX(begin: 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── MARKET PRICES TAB ───────────
  Widget _buildMarketTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'APMC Mandi Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CropDocColors.textPrimary,
              ),
            ),
            Text(
              'Updated Today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: CropDocColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Harvest recommendation card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE76F51), Color(0xFFF4A261)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE76F51).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_down_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harvest Tomato Now!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prices dropping. Expected to fall 15% next week due to high yield supply.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Market Price Items
        _buildPriceCard(
          crop: 'Tomato',
          mandi: 'Pune APMC',
          price: '₹ 2,400',
          unit: '/ Quintal',
          trendPercent: -4.2,
          isActionable: true,
          actionText: 'SELL NOW',
        ),
        const SizedBox(height: 16),
        _buildPriceCard(
          crop: 'Onion',
          mandi: 'Lasalgaon Mandi',
          price: '₹ 3,100',
          unit: '/ Quintal',
          trendPercent: 12.5,
          isActionable: true,
          actionText: 'WAIT 1 WEEK',
          actionColor: const Color(0xFF2EAC68),
        ),
        const SizedBox(height: 16),
        _buildPriceCard(
          crop: 'Potato',
          mandi: 'Nashik APMC',
          price: '₹ 1,800',
          unit: '/ Quintal',
          trendPercent: 1.1,
          isActionable: false,
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String crop,
    required String mandi,
    required String price,
    required String unit,
    required double trendPercent,
    required bool isActionable,
    String? actionText,
    Color? actionColor,
  }) {
    final isUp = trendPercent > 0;
    final trendColor = isUp ? const Color(0xFF2EAC68) : const Color(0xFFE76F51);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CropDocColors.divider),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CropDocColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    crop.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: CropDocColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CropDocColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mandi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CropDocColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CropDocColors.textPrimary,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CropDocColors.textMuted,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: trendColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trendPercent.abs()}% today',
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isActionable && actionText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (actionColor ?? const Color(0xFFE76F51)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }

  // ─────────── GOVT SCHEMES TAB ───────────
  Widget _buildSchemesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        const Text(
          'Active Schemes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CropDocColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildSchemeCard(
          title: 'PM-KISAN Samman Nidhi',
          subtitle: '₹6,000 yearly income support. Next installment due in 15 days.',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF4361EE),
          buttonText: 'Check Eligibility',
        ),
        const SizedBox(height: 16),
        
        _buildSchemeCard(
          title: 'Crop Insurance (PMFBY)',
          subtitle: 'Kharif season enrollment ends in 10 days! Secure your crop against weather risks.',
          icon: Icons.security_rounded,
          color: const Color(0xFF2EAC68),
          buttonText: 'Enroll Now',
          isUrgent: true,
        ),
        const SizedBox(height: 16),
        
        _buildSchemeCard(
          title: 'Fertilizer Subsidy Status',
          subtitle: 'Urea and DAP subsides active. Update Aadhaar to ensure direct benefit transfer.',
          icon: Icons.science_rounded,
          color: const Color(0xFF8338EC),
          buttonText: 'Link Aadhaar',
        ),
      ],
    );
  }

  Widget _buildSchemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String buttonText,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? const Color(0xFFE76F51).withValues(alpha: 0.5) : CropDocColors.divider,
          width: isUrgent ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isUrgent)
            BoxShadow(
              color: const Color(0xFFE76F51).withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CropDocColors.textPrimary,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE76F51).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Color(0xFFE76F51),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CropDocColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Mock action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirecting to government portal...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.1),
                foregroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
