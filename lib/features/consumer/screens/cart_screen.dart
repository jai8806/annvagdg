import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/annva_colors.dart';
import '../../../core/theme/annva_spacing.dart';
import '../../../core/theme/annva_text_styles.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

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
        title: Text(
          'Your Rescue Cart',
          style: AnnvaTextStyles.h1.copyWith(fontSize: 24),
        ),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, ref, cartItems, cartNotifier),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AnnvaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 80)),
            const SizedBox(height: AnnvaSpacing.lg),
            Text('Your cart is empty', style: AnnvaTextStyles.h2),
            const SizedBox(height: AnnvaSpacing.sm),
            Text(
              'Browse the live cascade to rescue food near you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'WorkSans',
                color: AnnvaColors.muted,
              ),
            ),
            const SizedBox(height: AnnvaSpacing.xl),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnvaColors.primary,
                foregroundColor: AnnvaColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AnnvaRadius.full),
                ),
              ),
              child: Text(
                'Browse listings →',
                style: TextStyle(
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cartItems,
    CartNotifier cartNotifier,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Dismissible(
                key: Key(item.listingId),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  cartNotifier.removeItem(item.listingId);
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                  decoration: BoxDecoration(
                    color: AnnvaColors.cascadeUrgent,
                    borderRadius: BorderRadius.circular(AnnvaRadius.lg),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AnnvaSpacing.md),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AnnvaColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AnnvaRadius.lg),
                    border: Border.all(color: AnnvaColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AnnvaColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(AnnvaRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.listing.imageUrl,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.listing.name,
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.listing.sellerName,
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                color: AnnvaColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg',
                              style: TextStyle(
                                fontFamily: 'WorkSans',
                                color: AnnvaColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${item.totalPrice.toStringAsFixed(0)}',
                            style: AnnvaTextStyles.price,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: AnnvaColors.muted,
                            ),
                            onPressed: () =>
                                cartNotifier.removeItem(item.listingId),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Order Summary
        Container(
          padding: const EdgeInsets.all(AnnvaSpacing.containerPadding),
          decoration: const BoxDecoration(
            color: AnnvaColors.background,
            border: Border(top: BorderSide(color: AnnvaColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AnnvaColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AnnvaRadius.xl),
                  border: Border.all(color: AnnvaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER SUMMARY', style: AnnvaTextStyles.label),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Subtotal',
                      '₹${cartNotifier.subtotal.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Rescue discount',
                      '-₹${cartNotifier.totalSavings.toStringAsFixed(0)}',
                      valueColor: AnnvaColors.cascadeFresh,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Delivery', 'Free (rescue order)'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AnnvaColors.border, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${cartNotifier.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AnnvaColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You\'re saving ₹${cartNotifier.totalSavings.toStringAsFixed(0)} and rescuing ${cartNotifier.totalKg.toStringAsFixed(1).replaceAll('.0', '')}kg from waste 🌱',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AnnvaColors.muted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment coming soon — Razorpay integration in next build',
                        ),
                      ),
                    );
                    // context.go('/consumer/checkout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnnvaColors.primary,
                    foregroundColor: AnnvaColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AnnvaRadius.full),
                    ),
                  ),
                  child: Text(
                    'Proceed to Pay →',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Bottom safe area
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'WorkSans', color: AnnvaColors.muted),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'WorkSans',
            color: valueColor ?? AnnvaColors.primary,
            fontWeight: valueColor != null
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
