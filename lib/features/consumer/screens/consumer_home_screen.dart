import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/providers/listings_provider.dart';
import '../../../shared/widgets/annva_logo.dart';
import '../../../shared/widgets/food_listing_card.dart';
import '../providers/cart_provider.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Urgent 🔴', 'Veg', 'Bakery', 'Restaurant', 'Kirana'];

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);
    final cartItems = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AnnvaColors.primary, size: 18),
                onPressed: () => context.pop(),
              )
            : null,
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: const AnnvaLogo(fontSize: 24),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AnnvaColors.primary),
                onPressed: () => context.push('/consumer/cart'),
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AnnvaColors.cascadeUrgent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: GoogleFonts.workSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AnnvaColors.ochre,
        backgroundColor: AnnvaColors.backgroundCard,
        onRefresh: () async {
          ref.invalidate(activeListingsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Impact mini-bar
            SliverToBoxAdapter(
              child: Container(
                height: 36,
                color: AnnvaColors.creamLight,
                alignment: Alignment.center,
                child: Text(
                  '487,312 kg rescued this month · 6 cities',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AnnvaColors.ochre,
                  ),
                ),
              ),
            ),
            
            // Filter chips row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AnnvaSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: AnnvaSpacing.sm),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AnnvaColors.primary : AnnvaColors.backgroundCard,
                              borderRadius: BorderRadius.circular(AnnvaRadius.full),
                              border: Border.all(
                                color: isSelected ? AnnvaColors.primary : AnnvaColors.border,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AnnvaColors.primaryForeground : AnnvaColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AnnvaSpacing.containerPadding,
                  AnnvaSpacing.sm,
                  AnnvaSpacing.containerPadding,
                  AnnvaSpacing.md,
                ),
                child: listingsAsync.when(
                  data: (listings) => Text(
                    'LIVE CASCADE · ${listings.length} active near you',
                    style: AnnvaTextStyles.label,
                  ),
                  loading: () => Text(
                    'LIVE CASCADE · loading...',
                    style: AnnvaTextStyles.label,
                  ),
                  error: (_, __) => Text(
                    'LIVE CASCADE · offline',
                    style: AnnvaTextStyles.label,
                  ),
                ),
              ),
            ),

            // Listings Feed
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AnnvaSpacing.containerPadding),
              sliver: listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AnnvaSpacing.xl),
                          child: Text(
                            'No active rescues near you right now.\nCheck back soon!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(color: AnnvaColors.muted),
                          ),
                        ),
                      ),
                    );
                  }

                  // Apply basic mock filtering for the UI
                  var filteredListings = listings;
                  if (_selectedFilter == 'Urgent 🔴') {
                    filteredListings = listings.where((l) => l.stage.name == 'urgent').toList();
                  } else if (_selectedFilter == 'Veg') {
                    filteredListings = listings.where((l) => l.diet.contains('veg')).toList();
                  } else if (_selectedFilter != 'All') {
                    filteredListings = listings.where((l) => l.vertical == _selectedFilter).toList();
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = filteredListings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                          child: FoodListingCard(
                            listing: listing,
                            onTap: () => context.push('/consumer/listing/${listing.id}'),
                            onRescueTap: () => context.push('/consumer/listing/${listing.id}'),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (index * 60).ms,
                          curve: Curves.easeOut,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          delay: (index * 60).ms,
                          curve: Curves.easeOut,
                        );
                      },
                      childCount: filteredListings.length,
                    ),
                  );
                },
                loading: () {
                  // Shimmer skeletons
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: AnnvaColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: 1200.ms,
                            color: AnnvaColors.backgroundCard.withValues(alpha: 0.6),
                          ),
                        );
                      },
                      childCount: 4,
                    ),
                  );
                },
                error: (e, st) {
                  debugPrint('🔴 Firestore error: $e\n$st');
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AnnvaSpacing.xl),
                        child: Text(
                          'Something moved.\nPull to refresh.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(color: AnnvaColors.muted),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: AnnvaSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}
