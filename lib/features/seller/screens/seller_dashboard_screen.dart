import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../../../shared/widgets/food_listing_card.dart';
import '../../../shared/widgets/certification_widgets.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        title: const AnnvaLogo(fontSize: 24),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. SELLER HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELLER DASHBOARD',
                    style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
                  ),
                  const SizedBox(height: 8),
                  Text("Ravi's Kitchen", style: AnnvaTextStyles.h1),
                  const SizedBox(height: 4),
                  const Text(
                    'MTR — Lalbagh · Partner since 2024',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CERTIFICATION BADGE CARD
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding, vertical: AnnvaSpacing.sm),
              child: PartnerCertificationCard(
                title: 'ANNVA Gold Partner',
                message: 'Great job! You are making a real impact by reducing waste at the source.',
                badgeLabel: 'GOLD PARTNER',
              ),
            ),
          ),

          // 3. STATS CARDS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding),
              child: Column(
                children: [
                  _buildStatCard(
                    'RECOVERED TODAY',
                    '₹9,840',
                    '12 rescues completed',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          'ALCHEMYSCORE',
                          '✦ 782/900',
                          'Top 5% in BLR',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMiniCard(
                          'BRSR ESG',
                          'EXPORT',
                          'Ready for FY24',
                          isAction: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. INCOMING ORDERS (If any)
          _buildIncomingOrders(),

          // 4. LIVE LISTINGS HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.xl,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Text(
                'YOUR LIVE LISTINGS',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
            ),
          ),

          // 6. LIVE LISTINGS STREAM
          _buildLiveListings(),

          // 7. QUICK IMPACT STRIP
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: ImpactSummaryStrip(
                metrics: [
                  ImpactMetric('Food Saved', '218 kg', Icons.eco, AnnvaColors.cascadeFresh),
                  ImpactMetric('CO2 Reduced', '510 kg', Icons.cloud_queue, Colors.blueGrey),
                  ImpactMetric('Water Saved', '21,000 L', Icons.water_drop, Colors.blue),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/list'),
        backgroundColor: AnnvaColors.ochre,
        icon: const Icon(Icons.add, color: AnnvaColors.creamLight),
        label: const Text(
          'List item',
          style: TextStyle(
            fontFamily: 'WorkSans',
            fontWeight: FontWeight.w500,
            color: AnnvaColors.creamLight,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.primary,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AnnvaColors.ochre,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AnnvaTextStyles.h1.copyWith(color: Colors.white, fontSize: 32),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  color: AnnvaColors.creamLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Icon(icon, color: AnnvaColors.ochre.withValues(alpha: 0.2), size: 48),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String label, String value, String sub, {bool isAction = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAction ? AnnvaColors.backgroundCard : AnnvaColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AnnvaTextStyles.label,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'WorkSans',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AnnvaColors.primary,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'WorkSans',
              color: AnnvaColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: 's1')
          .where('status', isEqualTo: 'confirmed')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final orders = snapshot.data!.docs;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'INCOMING ORDERS',
                  style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
                ),
                const SizedBox(height: 12),
                ...orders.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildOrderCard(context, doc.id, data);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Row(
        children: [
          const Text('📦', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['foodName'] ?? 'Rescue Order',
                  style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Code: ${data['pickupCode']}',
                  style: AnnvaTextStyles.mono,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmPickup(context, orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AnnvaColors.cascadeFresh,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPickup(BuildContext context, String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'picked_up'});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup confirmed! ✓')),
      );
    }
  }

  Widget _buildLiveListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('sellerId', isEqualTo: 's1')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AnnvaSpacing.xl),
              child: Center(
                child: Text(
                  'No active listings. Tap List Item below.',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.muted,
                  ),
                ),
              ),
            ),
          );
        }

        final now = DateTime.now();
        final listings = docs
            .map((doc) => FoodListing.fromFirestore(doc))
            .where((listing) => listing.expiresAt.isAfter(now))
            .toList();
        listings.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                child: FoodListingCard(
                  listing: listings[index],
                  onTap: () {},
                  onRescueTap: () {},
                ),
              );
            }, childCount: listings.length),
          ),
        );
      },
    );
  }
}
