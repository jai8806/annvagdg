import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../../../shared/widgets/certification_widgets.dart';

class NgoHomeScreen extends ConsumerWidget {
  const NgoHomeScreen({super.key});

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
          // 1. NGO HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NGO',
                    style: AnnvaTextStyles.label.copyWith(
                      color: AnnvaColors.ochre,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Akshaya Patra', style: AnnvaTextStyles.h1),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Bengaluru chapter · Verified partner',
                        style: AnnvaTextStyles.bodySmall.copyWith(
                          color: AnnvaColors.muted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AnnvaColors.cascadeFresh.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '✓ Verified',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            color: AnnvaColors.cascadeFresh,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. STATS ROW
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AnnvaSpacing.containerPadding,
                ),
                children: [
                  _buildStatCard(
                    'MEALS THIS MONTH',
                    '14,280',
                    '+340 this week',
                  ),
                  const SizedBox(width: AnnvaSpacing.sm),
                  _buildStatCard(
                    'KG RECEIVED',
                    '3,842',
                    'from 48 rescue events',
                  ),
                  const SizedBox(width: AnnvaSpacing.sm),
                  _buildStatCard('VOLUNTEERS', '23 active', 'across Bengaluru'),
                ],
              ),
            ),
          ),

          // 2.1 IMPACT STRIP
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding, vertical: AnnvaSpacing.lg),
              child: ImpactSummaryStrip(
                metrics: [
                  ImpactMetric('Food Rescued', '3,842 kg', Icons.eco, AnnvaColors.cascadeFresh),
                  ImpactMetric('Families Fed', '1,200', Icons.people, Colors.blue),
                  ImpactMetric('Impact Score', '9.8/10', Icons.star, AnnvaColors.ochre),
                ],
              ),
            ),
          ),

          // 3. INCOMING CASCADE ALERTS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.xl,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INCOMING RESCUES',
                    style: AnnvaTextStyles.label.copyWith(
                      color: AnnvaColors.ochre,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AnnvaColors.cascadeUrgent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '3 urgent',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          color: AnnvaColors.cascadeUrgent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildAlertsStream(),

          // 4. RECENT RECEIVALS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.xl,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Text(
                'RECENT RECEIVALS',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AnnvaSpacing.containerPadding,
              ),
              child: Column(
                children: [
                  _buildReceivalTile(
                    '🍲',
                    'Bisi bele bath',
                    '8kg',
                    'Apr 18',
                    'Karthik',
                  ),
                  const SizedBox(height: 8),
                  _buildReceivalTile(
                    '🥐',
                    'Croissants',
                    '3kg',
                    'Apr 15',
                    'Priya',
                  ),
                  const SizedBox(height: 8),
                  _buildReceivalTile(
                    '🍛',
                    'Wedding biryani',
                    '40kg',
                    'Apr 12',
                    'Raju',
                  ),
                ],
              ),
            ),
          ),

          // 5. COORDINATION MAP
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.xl,
                AnnvaSpacing.containerPadding,
                AnnvaSpacing.sm,
              ),
              child: Text(
                'VOLUNTEER POSITIONS',
                style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AnnvaSpacing.containerPadding,
              ),
              child: _buildMap(),
            ),
          ),

          // 6. CERTIFICATES & COMPLIANCE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'CERTIFICATES & COMPLIANCE',
                    style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
                  ),
                  const SizedBox(height: 16),
                  const CredentialItem(
                    title: 'FSSAI Verified NGO',
                    date: 'Valid till Dec 2026',
                    description: 'Compliant with food safety and standards for redistribution.',
                    icon: Icons.verified_user,
                    color: Colors.green,
                  ),
                  const CredentialItem(
                    title: '80G Tax Exemption',
                    date: 'Active',
                    description: 'Eligible for donor tax benefits under Section 80G.',
                    icon: Icons.account_balance,
                    color: AnnvaColors.primary,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AnnvaSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtext) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.ochre),
          ),
          const Spacer(),
          Text(
            value,
            style: AnnvaTextStyles.h1.copyWith(
              color: AnnvaColors.primary,
              fontSize: 40,
            ),
          ),
          Text(
            subtext,
            style: const TextStyle(
              fontFamily: 'WorkSans',
              color: AnnvaColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('stage', isEqualTo: 'urgent')
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
                  'No urgent rescues incoming.',
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

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.containerPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildAlertTile(context, listings[index]);
            }, childCount: listings.length),
          ),
        );
      },
    );
  }

  Widget _buildAlertTile(BuildContext context, FoodListing listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: AnnvaSpacing.md),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AnnvaColors.cascadeUrgent, width: 3),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '[URGENT]',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.cascadeUrgent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${listing.name} · ${listing.sellerName}',
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${listing.qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg · ${listing.servings} servings · Volunteer: Karthik',
              style: const TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AnnvaColors.cascadeUrgent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${listing.expiresAt.difference(DateTime.now()).inMinutes}m remaining',
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.cascadeUrgent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: AnnvaColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Rescue accepted. Karthik is on the way.',
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Accept batch →',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivalTile(
    String emoji,
    String name,
    String qty,
    String date,
    String volunteer,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AnnvaColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AnnvaRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · $qty',
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$date · Volunteer: $volunteer',
                  style: const TextStyle(
                    fontFamily: 'WorkSans',
                    color: AnnvaColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AnnvaColors.cascadeFresh.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '✓ RECEIVED',
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.cascadeFresh,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(
              12.9550,
              77.6200,
            ), // Center roughly covering all markers
            initialZoom: 11.5,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
            backgroundColor: AnnvaColors.background,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.annva.annva',
              tileProvider: NetworkTileProvider(
                headers: {'User-Agent': 'AnnvaApp/1.0 (contact@annva.in)'},
              ),
              maxZoom: 19,
              minZoom: 3,
            ),
            MarkerLayer(
              markers: [
                // Volunteers
                const Marker(
                  point: LatLng(12.9507, 77.5848), // Lalbagh (Karthik)
                  child: Icon(Icons.circle, color: Colors.blue, size: 16),
                ),
                const Marker(
                  point: LatLng(12.9352, 77.6245), // Koramangala (Priya)
                  child: Icon(Icons.circle, color: Colors.blue, size: 16),
                ),
                const Marker(
                  point: LatLng(12.9698, 77.7500), // Whitefield (Raju)
                  child: Icon(Icons.circle, color: Colors.blue, size: 16),
                ),
                // NGO HQ
                Marker(
                  point: const LatLng(12.9716, 77.5946), // HQ
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AnnvaColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
