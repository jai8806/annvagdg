import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  DemoRole _activeRole = DemoRole.consumer;

  @override
  Widget build(BuildContext context) {
    // Initialize cleanup timer
    ref.watch(priceLockCleanupProvider);
    
    final listings = getMockListings();

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── STICKY HEADER: Logo + Role Switcher ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AnnvaSpacing.containerPadding,
                  AnnvaSpacing.md,
                  AnnvaSpacing.containerPadding,
                  0,
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
                            // Logo wordmark
                            const AnnvaLogo(fontSize: 26),
                            const SizedBox(height: 4),
                            // Tagline
                            Text(
                              'Food That Moves.',
                              style: GoogleFonts.workSans(
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
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Firestore seeded!')),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AnnvaColors.ochre.withValues(alpha: 0.1),
                                  foregroundColor: AnnvaColors.ochre,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AnnvaRadius.full),
                                  ),
                                ),
                                child: Text(
                                  'Seed',
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (kDebugMode) const SizedBox(width: AnnvaSpacing.sm),
                            // Sign in button for demo
                            TextButton(
                              onPressed: () => context.go('/auth'),
                              style: TextButton.styleFrom(
                                backgroundColor: AnnvaColors.primary.withValues(alpha: 0.1),
                                foregroundColor: AnnvaColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AnnvaRadius.full),
                                ),
                              ),
                              child: Text(
                                'Sign in',
                                style: GoogleFonts.workSans(
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

                    // Role switcher pill
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: RoleSwitcher(
                        activeRole: _activeRole,
                        onRoleChanged: (role) {
                          setState(() => _activeRole = role);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── IMPACT STATS ROW ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AnnvaSpacing.containerPadding,
                  vertical: AnnvaSpacing.lg,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AnnvaSpacing.lg,
                    vertical: AnnvaSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AnnvaColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                    border: Border.all(
                      color: AnnvaColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ImpactTicker(
                        initialValue: liveImpact['kgRescued']!,
                        label: 'kg rescued',
                        fontSize: 28,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AnnvaColors.border,
                      ),
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
                    ),
              ),
            ),

            // ─── SECTION LABEL ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AnnvaSpacing.containerPadding,
                  0,
                  AnnvaSpacing.containerPadding,
                  AnnvaSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'LIVE CASCADE',
                      style: AnnvaTextStyles.label,
                    ),
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
                      '${listings.length} active',
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AnnvaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── FOOD LISTING CARDS — staggered animation ───
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AnnvaSpacing.containerPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final listing = listings[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AnnvaSpacing.md,
                      ),
                      child: FoodListingCard(
                        listing: listing,
                        onTap: () => _showListingSnackbar(context, listing.name),
                        onRescueTap: () =>
                            _showRescueSnackbar(context, listing.name),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (100 + index * 50).ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 400.ms,
                          delay: (100 + index * 50).ms,
                          curve: Curves.easeOut,
                        );
                  },
                  childCount: listings.length,
                ),
              ),
            ),

            // ─── HEATMAP SECTION ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AnnvaSpacing.xl,
                  bottom: AnnvaSpacing.md,
                ),
                child: const DemoHeatmap()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
              ),
            ),

            // ─── BOTTOM PADDING ───
            const SliverToBoxAdapter(
              child: SizedBox(height: AnnvaSpacing.xxl),
            ),
          ],
        ),
      ),
    );
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
