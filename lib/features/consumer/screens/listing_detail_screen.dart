import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../../../shared/models/food_listing.dart';
import '../../../shared/providers/listings_provider.dart';
import '../../../shared/widgets/cascade_badge.dart';
import '../providers/price_lock_provider.dart';
import '../providers/cart_provider.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  double _qty = 1.0;
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: listingsAsync.when(
        data: (listings) {
          final auth = ref.watch(authNotifierProvider);
          final currentUserId = auth.userId;

          final listing = listings.cast<FoodListing?>().firstWhere(
            (l) => l?.id == widget.listingId,
            orElse: () => null,
          );

          if (listing == null) {
            return _buildErrorState('Listing not found or expired.');
          }

          // Force qty bounds
          if (_qty > listing.qtyKg) _qty = listing.qtyKg;

          final pricePerKg = listing.qtyKg > 0
              ? listing.currentPrice / listing.qtyKg
              : 0;
          final totalPrice = pricePerKg * _qty;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Hero Section
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: AnnvaColors.backgroundSecondary,
                            alignment: Alignment.center,
                            child: Text(
                              listing.imageUrl, // emoji
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          // Gradient Overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AnnvaColors.background.withOpacity(0),
                                    AnnvaColors.background,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Back Arrow
                          Positioned(
                            top: 48,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AnnvaColors.background.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AnnvaColors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          // Cascade Badge
                          Positioned(
                            top: 48,
                            right: 16,
                            child: CascadeBadge(stage: listing.stage),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Section
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AnnvaSpacing.md),
                        Text(listing.name, style: AnnvaTextStyles.h1),
                        const SizedBox(height: 4),
                        Text(
                          listing.sellerLabel,
                          style: const TextStyle(
                            fontFamily: 'WorkSans',
                            color: AnnvaColors.muted,
                            fontSize: 13,
                          ),
                        ),

                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: 1,
                          color: AnnvaColors.border,
                        ),

                        // Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (listing.currentPrice > 0) ...[
                                  Text(
                                    listing.formattedPrice,
                                    style: AnnvaTextStyles.price,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    listing.formattedOriginalPrice,
                                    style: TextStyle(
                                      fontFamily: 'WorkSans',
                                      color: AnnvaColors.muted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AnnvaColors.cascadeUrgent
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        AnnvaRadius.sm,
                                      ),
                                    ),
                                    child: const Text(
                                      'FREE PICKUP',
                                      style: TextStyle(
                                        fontFamily: 'WorkSans',
                                        color: AnnvaColors.cascadeUrgent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              listing.quantityLabel,
                              style: const TextStyle(
                                fontFamily: 'WorkSans',
                                color: AnnvaColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AnnvaSpacing.xl),

                        // Urgency Timer
                        _buildUrgencyTimer(listing.expiresAt),

                        const SizedBox(height: AnnvaSpacing.lg),

                        // Price Lock Section
                        _buildPriceLockSection(listing, currentUserId),

                        const SizedBox(height: AnnvaSpacing.xl),

                        // Divider
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          height: 1,
                          color: AnnvaColors.border,
                        ),

                        // About Section
                        Text('ABOUT THIS RESCUE', style: AnnvaTextStyles.label),
                        const SizedBox(height: AnnvaSpacing.sm),
                        Wrap(
                          spacing: 8,
                          children: listing.diet.map((d) {
                            String emoji = d.toLowerCase().contains('veg')
                                ? '🌱'
                                : '🥩';
                            return Chip(
                              label: Text(
                                '$emoji ${d[0].toUpperCase()}${d.substring(1)}',
                              ),
                              backgroundColor: AnnvaColors.backgroundCard,
                              side: const BorderSide(color: AnnvaColors.border),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AnnvaSpacing.md),
                        Text(
                          '${listing.sellerName} has ${listing.qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg of ${listing.name} available for rescue. Enough for ${listing.servings} people.',
                          style: const TextStyle(
                            fontFamily: 'WorkSans',
                            color: AnnvaColors.primary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Seller Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AnnvaColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                            border: Border.all(color: AnnvaColors.border),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getVerticalEmoji(listing.vertical),
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      listing.sellerName,
                                      style: const TextStyle(
                                        fontFamily: 'WorkSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      listing.address,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AnnvaColors.border.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                    AnnvaRadius.full,
                                  ),
                                ),
                                child: Text(
                                  listing.vertical,
                                  style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          height: 1,
                          color: AnnvaColors.border,
                        ),

                        // Quantity Selector
                        Text(
                          'HOW MUCH DO YOU NEED?',
                          style: AnnvaTextStyles.label,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _qty > 1.0
                                  ? () => setState(() => _qty -= 1.0)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AnnvaColors.primary,
                              iconSize: 32,
                            ),
                            const SizedBox(width: 24),
                            Text(
                              '${_qty.toStringAsFixed(1).replaceAll('.0', '')} kg',
                              style: AnnvaTextStyles.h1,
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              onPressed: _qty < listing.qtyKg
                                  ? () => setState(() => _qty += 1.0)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AnnvaColors.primary,
                              iconSize: 32,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 120,
                        ), // Padding for sticky bottom bar
                      ]),
                    ),
                  ),
                ],
              ),

              // Bottom Sticky Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: AnnvaColors.backgroundCard,
                    border: Border(top: BorderSide(color: AnnvaColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${totalPrice.toStringAsFixed(0)}',
                            style: AnnvaTextStyles.h1.copyWith(fontSize: 24),
                          ),
                          Text(
                            'for ${_qty.toStringAsFixed(1).replaceAll('.0', '')}kg',
                            style: const TextStyle(
                              fontFamily: 'WorkSans',
                              color: AnnvaColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addItem(listing, _qty);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to your rescue cart!'),
                            ),
                          );
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AnnvaColors.primary,
                          foregroundColor: AnnvaColors.primaryForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AnnvaRadius.full,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Add to Cart →',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AnnvaColors.primary),
        ),
        error: (err, _) => _buildErrorState('Something went wrong.'),
      ),
    );
  }

  Widget _buildUrgencyTimer(DateTime expiresAt) {
    final diff = expiresAt.difference(_now);
    final isExpired = diff.isNegative;

    if (isExpired) {
      return Center(
        child: Text(
          'EXPIRED',
          style: AnnvaTextStyles.h2.copyWith(color: AnnvaColors.muted),
        ),
      );
    }

    final hh = diff.inHours.toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (diff.inSeconds % 60).toString().padLeft(2, '0');

    Color timerColor;
    bool isUrgent = false;

    if (diff.inHours > 6) {
      timerColor = AnnvaColors.cascadeFresh;
    } else if (diff.inHours >= 2) {
      timerColor = AnnvaColors.cascadeMid;
    } else {
      timerColor = AnnvaColors.cascadeUrgent;
      isUrgent = true;
    }

    Widget timerText = Text(
      '⏱ ${hh}h ${mm}m ${ss}s remaining',
      style: AnnvaTextStyles.h2.copyWith(color: timerColor),
      textAlign: TextAlign.center,
    );

    if (isUrgent) {
      timerText = timerText
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 800.ms,
            curve: Curves.easeInOut,
          )
          .tint(color: Colors.red.withOpacity(0.2));
    }

    return Center(child: timerText);
  }

  Widget _buildPriceLockSection(FoodListing listing, String? currentUserId) {
    final isLockedByMe =
        listing.lockedByUserId != null &&
        listing.lockedByUserId == currentUserId;
    final isLockedByOther =
        listing.lockedByUserId != null &&
        listing.lockedByUserId != currentUserId &&
        listing.lockedUntil != null &&
        listing.lockedUntil!.isAfter(_now);

    if (isLockedByMe) {
      final diff = listing.lockedUntil!.difference(_now);
      final mm = diff.inMinutes.toString().padLeft(2, '0');
      final ss = (diff.inSeconds % 60).toString().padLeft(2, '0');

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AnnvaColors.cascadeFresh.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AnnvaRadius.xl),
          border: Border.all(color: AnnvaColors.cascadeFresh),
        ),
        child: Column(
          children: [
            Text(
              '🔒 Price locked at ₹${listing.lockedPrice?.round()}',
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontWeight: FontWeight.bold,
                color: AnnvaColors.cascadeFresh,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$mm:$ss remaining',
              style: const TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12,
                color: AnnvaColors.cascadeFresh,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '"Add to cart to secure this deal →"',
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AnnvaColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (isLockedByOther) {
      final diff = listing.lockedUntil!.difference(_now);
      final mm = diff.inMinutes.toString().padLeft(2, '0');
      final ss = (diff.inSeconds % 60).toString().padLeft(2, '0');

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundCard,
          borderRadius: BorderRadius.circular(AnnvaRadius.xl),
          border: Border.all(color: AnnvaColors.border),
        ),
        child: Column(
          children: [
            const Text(
              '🔒 Someone locked this price',
              style: TextStyle(
                fontFamily: 'WorkSans',
                fontWeight: FontWeight.bold,
                color: AnnvaColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available in $mm:$ss',
              style: const TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 12,
                color: AnnvaColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ref
                    .read(priceLockNotifierProvider.notifier)
                    .notifyWhenUnlocked(
                      listing.id,
                      listing.name,
                      listing.currentPrice.toDouble(),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("We'll notify you when this unlocks ✓"),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AnnvaRadius.full),
                ),
                side: const BorderSide(color: AnnvaColors.primary),
              ),
              child: const Text('Notify me when it unlocks 🔔'),
            ),
          ],
        ),
      );
    }

    // No lock
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(AnnvaRadius.xl),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🔒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lock this price for 20 minutes',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontWeight: FontWeight.bold,
                        color: AnnvaColors.primary,
                      ),
                    ),
                    const Text(
                      'Pay ₹10 deposit now. If you order within 20 min, ₹10 applies to total. If not, ₹10 goes to our NGO fund. 🌱',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontSize: 11,
                        color: AnnvaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(priceLockNotifierProvider.notifier)
                    .lockPrice(listing.id, listing.currentPrice.toDouble());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🔒 Price locked! You have 20 minutes. ₹10 deposit recorded.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnvaColors.ochre,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AnnvaRadius.full),
                ),
              ),
              child: Text(
                'Lock at ₹${listing.currentPrice} →',
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getVerticalEmoji(String vertical) {
    final v = vertical.toLowerCase();
    if (v.contains('bakery')) return '🥐';
    if (v.contains('kirana')) return '🏪';
    if (v.contains('temple')) return '🛕';
    if (v.contains('mosque')) return '🕌';
    return '🍽';
  }

  Widget _buildErrorState(String msg) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AnnvaColors.background, elevation: 0),
      backgroundColor: AnnvaColors.background,
      body: Center(
        child: Text(
          msg,
          style: const TextStyle(fontFamily: 'WorkSans', color: AnnvaColors.muted),
        ),
      ),
    );
  }
}
