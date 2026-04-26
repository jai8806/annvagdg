import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';
import '../../core/theme/annva_text_styles.dart';
import '../../shared/providers/listings_provider.dart';
import '../../shared/widgets/annva_logo.dart';
import '../../shared/widgets/food_listing_card.dart';
import '../../shared/widgets/impact_ticker.dart';
import '../../shared/widgets/role_switcher.dart';
import 'firestore_seeder.dart';
import 'mock_data.dart';
import 'widgets/demo_heatmap.dart';
import '../consumer/providers/price_lock_cleanup_provider.dart';

/// Hackathon demo screen — the full Annva experience with mock data.
///
/// No auth, no Firebase — runs entirely offline.
/// This is the Step 1 milestone: app runs, shows Bangalore listings,
/// cascade timers tick, impact counter animates.
class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key});

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  final ValueNotifier<String> _role = ValueNotifier('consumer');
  final ValueNotifier<int> _tick = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick.value = _tick.value + 1;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _role.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize cleanup timer
    ref.watch(priceLockCleanupProvider);

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AnnvaSpacing.containerPadding,
              AnnvaSpacing.md,
              AnnvaSpacing.containerPadding,
              AnnvaSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AnnvaLogo(fontSize: 26),
                        const SizedBox(height: 4),
                        Text(
                          'Food That Moves.',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: AnnvaColors.muted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (kDebugMode)
                          TextButton(
                            onPressed: () async {
                              await FirestoreSeeder.seedListings();
                              ref.invalidate(activeListingsProvider);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Firestore seeded!'),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AnnvaColors.ochre.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AnnvaColors.ochre,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AnnvaRadius.full,
                                ),
                              ),
                            ),
                            child: Text(
                              'Seed',
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (kDebugMode) const SizedBox(width: AnnvaSpacing.sm),
                        TextButton(
                          onPressed: () => context.go('/auth'),
                          style: TextButton.styleFrom(
                            backgroundColor: AnnvaColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AnnvaColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AnnvaRadius.full,
                              ),
                            ),
                          ),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'WorkSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AnnvaSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ValueListenableBuilder<String>(
                    valueListenable: _role,
                    builder: (context, role, _) => RoleSwitcher(
                      activeRole: _demoRoleFromString(role),
                      onRoleChanged: (newRole) =>
                          _role.value = _roleString(newRole),
                    ),
                  ),
                ),
                const SizedBox(height: AnnvaSpacing.lg),
                ValueListenableBuilder<String>(
                  valueListenable: _role,
                  builder: (context, role, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(role),
                        child: _buildRoleContent(role),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleContent(String role) {
    switch (role) {
      case 'seller':
        return _buildSellerContent();
      case 'volunteer':
        return _buildVolunteerContent();
      case 'ngo':
        return _buildNgoContent();
      case 'consumer':
      default:
        return _buildConsumerContent();
    }
  }

  Widget _buildConsumerContent() {
    final listings = getMockListings();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImpactCard(),
        const SizedBox(height: AnnvaSpacing.lg),
        _buildSectionHeader('LIVE CASCADE', '${listings.length} active'),
        const SizedBox(height: AnnvaSpacing.sm),
        ...listings.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
            child: FoodListingCard(
              listing: listing,
              onTap: () => _showListingSnackbar(context, listing.name),
              onRescueTap: () => _showRescueSnackbar(context, listing.name),
            ),
          ),
        ),
        const SizedBox(height: AnnvaSpacing.lg),
        const DemoHeatmap(),
      ],
    );
  }

  Widget _buildSellerContent() {
    final listings = getMockListings().take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: _MiniStatCard(label: 'RECOVERED TODAY', value: '₹9,840'),
            ),
            SizedBox(width: AnnvaSpacing.sm),
            Expanded(
              child: _MiniStatCard(label: 'ALCHEMYSCORE', value: '✦ 782/900'),
            ),
          ],
        ),
        const SizedBox(height: AnnvaSpacing.lg),
        Text('List surplus food', style: AnnvaTextStyles.h3),
        const SizedBox(height: AnnvaSpacing.sm),
        Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AnnvaColors.backgroundCard,
            borderRadius: BorderRadius.circular(AnnvaRadius.lg),
            border: Border.all(color: AnnvaColors.border, width: 0.7),
          ),
          child: Center(
            child: Text(
              'Upload box mock\nTap to upload image + auto-fill details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12,
                color: AnnvaColors.muted,
              ),
            ),
          ),
        ),
        const SizedBox(height: AnnvaSpacing.lg),
        _buildSectionHeader('YOUR LIVE LISTINGS', '${listings.length} active'),
        const SizedBox(height: AnnvaSpacing.sm),
        ...listings.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
            child: FoodListingCard(
              listing: listing,
              onTap: () => _showListingSnackbar(context, listing.name),
              onRescueTap: () => _showRescueSnackbar(context, listing.name),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AnnvaSpacing.md),
          decoration: BoxDecoration(
            color: AnnvaColors.primary,
            borderRadius: BorderRadius.circular(AnnvaRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Karthik · Silver tier · Bengaluru chapter',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AnnvaColors.primaryForeground,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: 64 / 125,
                  backgroundColor: AnnvaColors.primaryForeground.withValues(
                    alpha: 0.2,
                  ),
                  color: AnnvaColors.ochre,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '64 / 125 rescues to Gold',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 11,
                  color: AnnvaColors.primaryForeground.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AnnvaSpacing.lg),
        _buildSectionHeader('RESCUES NEAR YOU', '2 urgent'),
        const SizedBox(height: AnnvaSpacing.sm),
        _buildMissionTile('Temple prasad rice · 1.8km', 'Pickup within 24m'),
        const SizedBox(height: AnnvaSpacing.sm),
        _buildMissionTile('Wedding biryani · 2.4km', 'Pickup within 31m'),
      ],
    );
  }

  Widget _buildNgoContent() {
    return ValueListenableBuilder<int>(
      valueListenable: _tick,
      builder: (context, tick, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(
                  child: _MiniStatCard(label: 'MEALS', value: '14,280 meals'),
                ),
                SizedBox(width: AnnvaSpacing.sm),
                Expanded(
                  child: _MiniStatCard(label: 'RESCUED', value: '3,842 kg'),
                ),
                SizedBox(width: AnnvaSpacing.sm),
                Expanded(
                  child: _MiniStatCard(
                    label: 'VOLUNTEERS',
                    value: '23 volunteers',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AnnvaSpacing.lg),
            _buildSectionHeader('INCOMING RESCUES', '2 urgent'),
            const SizedBox(height: AnnvaSpacing.sm),
            _buildNgoTile(
              title: 'Event surplus thali set',
              countdown: _countdownLabel(34 * 60 - tick),
            ),
            const SizedBox(height: AnnvaSpacing.sm),
            _buildNgoTile(
              title: 'Fresh canteen khichdi',
              countdown: _countdownLabel(21 * 60 - tick),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImpactCard() {
    return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AnnvaSpacing.lg,
            vertical: AnnvaSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AnnvaColors.backgroundCard,
            borderRadius: BorderRadius.circular(AnnvaRadius.xl),
            border: Border.all(color: AnnvaColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImpactTicker(
                initialValue: liveImpact['kgRescued']!,
                label: 'kg rescued',
                fontSize: 28,
              ),
              Container(width: 1, height: 40, color: AnnvaColors.border),
              ImpactTicker(
                initialValue: liveImpact['mealsDelivered']!,
                label: 'meals served',
                fontSize: 28,
                numberColor: AnnvaColors.ochre,
                maxIncrement: 8,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Text(title, style: AnnvaTextStyles.label),
        const SizedBox(width: AnnvaSpacing.sm),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AnnvaColors.cascadeUrgent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AnnvaColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionTile(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AnnvaSpacing.md),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AnnvaTextStyles.bodySmall),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AnnvaColors.ochre.withValues(alpha: 0.12),
                foregroundColor: AnnvaColors.ochreDeep,
              ),
              child: const Text('Accept rescue →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNgoTile({required String title, required String countdown}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AnnvaSpacing.md),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Live countdown: $countdown',
            style: AnnvaTextStyles.bodySmall.copyWith(
              color: AnnvaColors.cascadeUrgent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text('Decline')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnnvaColors.primary,
                  foregroundColor: AnnvaColors.primaryForeground,
                ),
                child: const Text('Accept batch →'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _countdownLabel(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final mins = (safe ~/ 60).toString().padLeft(2, '0');
    final secs = (safe % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _roleString(DemoRole role) {
    switch (role) {
      case DemoRole.consumer:
        return 'consumer';
      case DemoRole.seller:
        return 'seller';
      case DemoRole.volunteer:
        return 'volunteer';
      case DemoRole.ngo:
        return 'ngo';
    }
  }

  DemoRole _demoRoleFromString(String role) {
    switch (role) {
      case 'seller':
        return DemoRole.seller;
      case 'volunteer':
        return DemoRole.volunteer;
      case 'ngo':
        return DemoRole.ngo;
      case 'consumer':
      default:
        return DemoRole.consumer;
    }
  }

  void _showListingSnackbar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: $name'),
        backgroundColor: AnnvaColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showRescueSnackbar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rescuing: $name 🎉'),
        backgroundColor: AnnvaColors.ochre,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnnvaRadius.md),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AnnvaSpacing.md),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.lg),
        border: Border.all(color: AnnvaColors.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 10,
              color: AnnvaColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 14,
              color: AnnvaColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
