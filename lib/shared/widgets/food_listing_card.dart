import 'package:flutter/material.dart';

import '../../core/theme/annva_colors.dart';
import '../../core/theme/annva_spacing.dart';
import '../../core/theme/annva_text_styles.dart';
import '../models/cascade_stage.dart';
import '../models/food_listing.dart';
import 'cascade_badge.dart';
import 'urgency_timer.dart';
import 'trust_badge.dart';

/// The most important component in the Annva app.
///
/// Shows one food item with its cascade stage, pricing, urgency timer,
/// and a "Rescue →" CTA button. Supports all three cascade stage variants.
///
/// Visual spec (Section 6.1):
/// ```
/// ┌─────────────────────────────────────────┐
/// │ [food image 80×80 rounded-lg]  [URGENT] │  ← stage badge, coloured
/// │                                         │
/// │ Bisi bele bath (catered)                │  ← Instrument Serif 18px
/// │ MTR — Lalbagh · Restaurant              │  ← Work Sans 12px muted
/// │                                         │
/// │ ₹480  ~~₹2,400~~   8 kg · 32 servings  │  ← price + original + quantity
/// │                                         │
/// │ ⏱ 1h 24m left    [Rescue →]            │  ← timer + CTA button
/// └─────────────────────────────────────────┘
/// ```
///
/// Stage-based styling:
/// - Fresh:  border-left 3px cascadeFresh, badge green, no pulse
/// - Mid:    border-left 3px cascadeMid, badge ochre, gentle glow
/// - Urgent: border-left 3px cascadeUrgent, badge red, urgency-pulse
///           If currentPrice == 0: show "FREE PICKUP" not a price
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';

class FoodListingCard extends ConsumerWidget {
  final FoodListing listing;

  /// Called when the user taps the card.
  final VoidCallback? onTap;

  /// Called when the user taps the "Rescue" CTA button.
  final VoidCallback? onRescueTap;

  const FoodListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onRescueTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final currentUserId = auth.userId;
    final stage = listing.stage;

    final isLockedByMe =
        listing.lockedByUserId != null &&
        listing.lockedByUserId == currentUserId;
    final isLockedByOther =
        listing.lockedByUserId != null &&
        listing.lockedByUserId != currentUserId &&
        listing.lockedUntil != null &&
        listing.lockedUntil!.isAfter(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AnnvaColors.backgroundCard,
          borderRadius: BorderRadius.circular(AnnvaRadius.lg),
          border: Border.all(
            color: AnnvaColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Left colour bar — 3px, stage-coloured ───
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 3,
                decoration: BoxDecoration(
                  color: stage.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AnnvaRadius.lg),
                    bottomLeft: Radius.circular(AnnvaRadius.lg),
                  ),
                ),
              ),

              // ─── Card content ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AnnvaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Image + badge
                      _buildHeaderRow(stage),
                      const SizedBox(height: AnnvaSpacing.sm),

                      // Row 2: Food name
                      Text(
                        listing.name,
                        style: const TextStyle(
                          fontFamily: 'InstrumentSerif',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AnnvaColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Row 3: Seller + location + vertical
                      Text(
                        listing.sellerLabel,
                        style: const TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AnnvaColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AnnvaSpacing.xs),

                      // Trust Badge
                      const TrustBadge(type: TrustBadgeType.certified),
                      const SizedBox(height: AnnvaSpacing.sm),

                      // Row 4: Price + quantity
                      _buildPriceRow(isLockedByMe),
                      const SizedBox(height: AnnvaSpacing.sm),
                      if (isLockedByOther)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AnnvaSpacing.xs,
                          ),
                          child: Text(
                            '🔒 Locked by another user · ${listing.lockedUntil!.difference(DateTime.now()).inMinutes}m left',
                            style: const TextStyle(
                              fontFamily: 'WorkSans',
                              color: AnnvaColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Row 5: Timer + CTA
                      _buildFooterRow(context, isLockedByMe, isLockedByOther),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top row: food image thumbnail + cascade stage badge.
  Widget _buildHeaderRow(CascadeStage stage) {
    String displayEmoji = listing.imageUrl.isNotEmpty
        ? listing.imageUrl
        : '🍽️';
    if (listing.vertical == 'Temple / Gurudwara') {
      displayEmoji = '🛕';
    } else if (listing.vertical == 'Mosque') {
      displayEmoji = '🕌';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food image — 80×80, rounded-lg, backgroundSecondary
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AnnvaColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(displayEmoji, style: const TextStyle(fontSize: 32)),
        ),
        const Spacer(),
        // Stage badge — top right
        CascadeBadge(stage: stage),
      ],
    );
  }

  /// Price row: current price, original price strikethrough, quantity.
  Widget _buildPriceRow(bool isLockedByMe) {
    final isFree = listing.currentPrice == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Current price or "FREE PICKUP"
            if (isFree)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AnnvaColors.cascadeUrgent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AnnvaRadius.sm),
                ),
                child: const Text(
                  'FREE PICKUP',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AnnvaColors.cascadeUrgent,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              Text(
                isLockedByMe
                    ? '₹${listing.lockedPrice?.round() ?? listing.currentPrice}'
                    : listing.formattedPrice,
                style: AnnvaTextStyles.price,
              ),

            if (!isFree) ...[
              const SizedBox(width: 8),
              // Original price — strikethrough
              Text(
                listing.formattedOriginalPrice,
                style: AnnvaTextStyles.priceOriginal,
              ),
            ],

            const SizedBox(width: 12),
            // Quantity label
            Expanded(
              child: Text(
                listing.quantityLabel,
                style: const TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AnnvaColors.muted,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (isLockedByMe)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '🔒 YOUR LOCK · ${listing.lockedUntil!.difference(DateTime.now()).inMinutes}m ${listing.lockedUntil!.difference(DateTime.now()).inSeconds % 60}s left',
              style: const TextStyle(
                fontFamily: 'WorkSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AnnvaColors.cascadeFresh,
              ),
            ),
          ),
      ],
    );
  }

  /// Bottom row: urgency timer + "Rescue →" CTA button.
  Widget _buildFooterRow(
    BuildContext context,
    bool isLockedByMe,
    bool isLockedByOther,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Timer
            UrgencyTimer(expiresAt: listing.expiresAt, fontSize: 13),
            const Spacer(),
            // Rescue CTA button
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: isLockedByOther ? null : onRescueTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLockedByOther
                      ? Colors.grey
                      : listing.stage.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AnnvaRadius.full),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Rescue →'),
              ),
            ),
          ],
        ),
        if (!isLockedByMe && !isLockedByOther)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () {
                // Navigate to detail for locking or handle here if we had detail
              },
              child: const Text(
                '🔒 Lock this price — ₹10',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AnnvaColors.ochre,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
