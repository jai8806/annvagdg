import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/widgets/annva_logo.dart';

class VolunteerHomeScreen extends ConsumerWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AnnvaColors.primary,
                  size: 18,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: const AnnvaLogo(fontSize: 24),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. VOLUNTEER HEADER + TIER CARD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: _buildHeaderCard(context),
            ),
          ),

          // 2. AVAILABLE RESCUES Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.lg,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RESCUES NEAR YOU',
                    style: AnnvaTextStyles.label.copyWith(
                      color: AnnvaColors.ochre,
                    ),
                  ),
                  const Text(
                    '4 urgent · 1.4 km radius',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. AVAILABLE RESCUES Stream
          _buildRescuesStream(),

          const SliverToBoxAdapter(child: SizedBox(height: AnnvaSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AnnvaColors.primary,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 160,
              color: AnnvaColors.creamLight.withOpacity(0.05),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VOLUNTEER',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AnnvaColors.ochre,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Karthik',
                  style: AnnvaTextStyles.h1.copyWith(
                    color: AnnvaColors.creamLight,
                    fontSize: 40,
                  ),
                ),
                const Text(
                  'Silver tier · Bengaluru chapter',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.creamLight,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Silver',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.creamLight,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Gold · 125 rescues',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.creamLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AnnvaColors.creamLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 64 / 125,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AnnvaColors.ochre,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '61 more rescues to Gold.',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.creamLight,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Row
                const Text(
                  '64 rescues · 805 kg delivered',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.creamLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    _buildActionButton(Icons.link, 'Share on LinkedIn', () {}),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.download,
                      'NCC/NSS Certificate',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Certificate download coming in next build',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AnnvaColors.creamLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AnnvaRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AnnvaColors.creamLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.creamLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRescuesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('stage', isEqualTo: 'urgent')
          .where('isActive', isEqualTo: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.xl),
              child: Center(
                child: const Text(
                  'No urgent rescues nearby right now.',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.muted,
                  ),
                ),
              ),
            ),
          );
        }

        final listings = docs
            .map((doc) => FoodListing.fromFirestore(doc))
            .toList();
        final distances = [0.8, 1.2, 1.6, 2.1];

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final distance = distances[index % distances.length];
              return _buildVolunteerMissionTile(
                context,
                listings[index],
                distance,
              );
            }, childCount: listings.length),
          ),
        );
      },
    );
  }

  Widget _buildVolunteerMissionTile(
    BuildContext context,
    FoodListing listing,
    double distanceKm,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AnnvaSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AnnvaColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AnnvaRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  listing.imageUrl,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.sellerName} · ${listing.address}',
                      style: const TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AnnvaColors.cascadeUrgent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.cascadeUrgent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AnnvaColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$distanceKm km away',
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${listing.qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg · ${listing.servings} servings',
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    _showAcceptBottomSheet(context, listing, distanceKm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AnnvaColors.cascadeUrgent,
                    borderRadius: BorderRadius.circular(AnnvaRadius.full),
                  ),
                  child: const Text(
                    'Accept rescue →',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptBottomSheet(
    BuildContext context,
    FoodListing listing,
    double distanceKm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: AnnvaColors.creamLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AnnvaRadius.xl),
                ),
              ),
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AnnvaColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AnnvaSpacing.lg),
                  const Center(child: AnnvaLogo(fontSize: 20)),
                  const SizedBox(height: AnnvaSpacing.lg),
                  Text(
                    'MISSION DETAILS',
                    style: AnnvaTextStyles.label.copyWith(
                      color: AnnvaColors.ochre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(listing.name, style: AnnvaTextStyles.h2),
                  Text(
                    'from ${listing.sellerName}',
                    style: AnnvaTextStyles.bodySmall.copyWith(
                      color: AnnvaColors.muted,
                    ),
                  ),

                  const SizedBox(height: AnnvaSpacing.xl),

                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Pickup',
                    value: listing.address,
                    action: GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(
                          'https://maps.google.com/?q=${listing.lat},${listing.lng}',
                        );
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                      child: const Text(
                        'Open in Maps →',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          color: AnnvaColors.ochre,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.scale_outlined,
                    label: 'Quantity',
                    value:
                        '${listing.qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg · ${listing.servings} servings',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.home_work_outlined,
                    label: 'Deliver to',
                    value: 'Akshaya Patra · Indiranagar',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.timer_outlined,
                    label: 'Urgency',
                    value:
                        '${listing.expiresAt.difference(DateTime.now()).inMinutes} minutes remaining',
                    valueColor: AnnvaColors.cascadeUrgent,
                  ),

                  const SizedBox(height: AnnvaSpacing.xl),
                  Text('YOUR IMPACT PREVIEW', style: AnnvaTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AnnvaColors.backgroundCard,
                      border: Border.all(color: AnnvaColors.border),
                      borderRadius: BorderRadius.circular(AnnvaRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildImpactStat('Rescues', '+1'),
                        _buildImpactStat('Food Saved', '+${listing.qtyKg}kg'),
                        _buildImpactStat(
                          'CO₂e',
                          '-${(listing.qtyKg * 2.5).toStringAsFixed(1)}kg',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AnnvaSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mission accepted! Navigation starting...',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnnvaColors.primary,
                        foregroundColor: AnnvaColors.primaryForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AnnvaRadius.full),
                        ),
                      ),
                      child: Text(
                        'Confirm Rescue',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AnnvaSpacing.xxl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? action,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AnnvaColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  color: AnnvaColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: valueColor ?? AnnvaColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildImpactStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AnnvaTextStyles.h2.copyWith(color: AnnvaColors.cascadeFresh),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            color: AnnvaColors.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
