import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:annva/core/theme/annva_colors.dart';
import 'package:annva/core/theme/annva_text_styles.dart';
import 'package:annva/features/consumer/providers/cart_provider.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';
import 'package:annva/shared/widgets/urgency_timer.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedMethod = 'UPI';
  final TextEditingController _upiController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _processMockPayment() async {
    setState(() => _isProcessing = true);

    // 1. Show loading overlay duration
    await Future.delayed(const Duration(milliseconds: 2200));

    final cartItems = ref.read(cartNotifierProvider);
    final total = ref.read(cartNotifierProvider.notifier).subtotal;
    final totalKg = ref.read(cartNotifierProvider.notifier).totalKg;
    final authState = ref.read(authNotifierProvider);
    
    if (cartItems.isEmpty || authState.userId == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // We assume all items are from the same seller for this rescue flow
    final firstItem = cartItems.first;
    final listing = firstItem.listing;
    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    final pickupCode = _generatePickupCode();

    try {
      // 2. Write order to Firestore
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'consumerId': authState.userId,
        'consumerName': authState.phoneNumber ?? 'Rescue Hero',
        'items': cartItems.map((item) => {
          'listingId': item.listingId,
          'name': item.listing.name,
          'qtyKg': item.qtyKg,
          'price': item.totalPrice,
        }).toList(),
        'totalAmount': total,
        'totalKg': totalKg,
        'paymentMethod': _selectedMethod,
        'status': 'confirmed',
        'pickupCode': pickupCode,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(listing.expiresAt),
        'sellerId': listing.sellerId,
        'sellerName': listing.sellerName,
        'sellerAddress': listing.address,
        'lat': listing.lat,
        'lng': listing.lng,
      });

      // 3. Update listing in Firestore (mark as inactive)
      // In a real multi-item cart, we'd handle partial quantities, but here we follow the prompt
      for (final item in cartItems) {
        await FirebaseFirestore.instance
            .collection('listings')
            .doc(item.listingId)
            .update({'isActive': false});
      }

      // 4. Clear cart
      ref.read(cartNotifierProvider.notifier).clearCart();

      if (mounted) {
        // 5. Navigate to OrderConfirmedScreen
        context.go('/consumer/order-confirmed/$orderId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _generatePickupCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartNotifierProvider);
    final notifier = ref.watch(cartNotifierProvider.notifier);
    final subtotal = notifier.subtotal;
    final savings = notifier.totalSavings;
    final authState = ref.watch(authNotifierProvider);

    if (cartItems.isEmpty && !_isProcessing) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Checkout", style: AnnvaTextStyles.h1),
          backgroundColor: AnnvaColors.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Your cart is empty"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/consumer'),
                child: const Text("Back to browsing"),
              ),
            ],
          ),
        ),
      );
    }

    // Check if any item is locked by user (to show price lock credit)
    // For simplicity, we just check the first item
    final hasActiveLock = cartItems.isNotEmpty && 
        cartItems.first.listing.lockedByUserId == authState.userId &&
        cartItems.first.listing.lockedUntil != null &&
        cartItems.first.listing.lockedUntil!.isAfter(DateTime.now());

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AnnvaColors.background,
          appBar: AppBar(
            backgroundColor: AnnvaColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AnnvaColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text("Checkout", style: AnnvaTextStyles.h1),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel("YOUR RESCUE ORDER"),
                _buildOrderSummaryCard(cartItems, savings, subtotal),
                const SizedBox(height: 24),
                
                _buildSectionLabel("PICKUP FROM"),
                _buildPickupDetailsCard(cartItems.first.listing),
                const SizedBox(height: 24),
                
                _buildSectionLabel("PAY WITH"),
                _buildPaymentMethodCard(),
                const SizedBox(height: 24),

                if (hasActiveLock) _buildPriceLockCredit(),
                
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
          bottomSheet: _buildStickyBottomBar(subtotal),
        ),
        if (_isProcessing) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(text, style: AnnvaTextStyles.label),
    );
  }

  Widget _buildOrderSummaryCard(List<CartItem> items, double savings, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        children: [
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text("🥘"),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.listing.name,
                    style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text("${item.qtyKg}kg", style: AnnvaTextStyles.bodySmall),
                const SizedBox(width: 12),
                Text("₹${item.totalPrice.toStringAsFixed(0)}", style: AnnvaTextStyles.body),
              ],
            ),
          )),
          const Divider(height: 24, color: AnnvaColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Rescue discount saved", style: AnnvaTextStyles.bodySmall),
              Text("-₹${savings.toStringAsFixed(0)}", 
                style: AnnvaTextStyles.bodySmall.copyWith(color: AnnvaColors.cascadeFresh)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pickup', style: AnnvaTextStyles.bodySmall),
              Text('Free', style: AnnvaTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: AnnvaTextStyles.h3),
              Text("₹${total.toStringAsFixed(0)}", 
                style: AnnvaTextStyles.h2.copyWith(fontSize: 24, color: AnnvaColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailsCard(listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🍽", style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.sellerName, style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    Text(listing.address, style: AnnvaTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${listing.lat},${listing.lng}")),
                      child: Text("📍 Open in Maps →", 
                        style: AnnvaTextStyles.bodySmall.copyWith(color: AnnvaColors.ochre, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AnnvaColors.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AnnvaColors.muted),
                    const SizedBox(width: 6),
                    Text("Pickup window:", style: AnnvaTextStyles.bodySmall),
                    const SizedBox(width: 4),
                    UrgencyTimer(expiresAt: listing.expiresAt),
                    Text(" remaining", style: AnnvaTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Pick up within this window to guarantee freshness.",
                  style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11, color: AnnvaColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        children: [
          _buildPaymentOption(
            id: 'UPI',
            title: 'UPI',
            subtitle: 'Pay via any UPI app',
            trailing: const Text('GPay · PhonePe · Paytm', 
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AnnvaColors.muted)),
          ),
          _buildPaymentOption(
            id: 'Card',
            title: 'Card',
            subtitle: 'Debit or Credit card',
          ),
          _buildPaymentOption(
            id: 'Net Banking',
            title: 'Net Banking',
            subtitle: 'Direct from your bank',
          ),
          _buildPaymentOption(
            id: 'Cash',
            title: 'Cash on Pickup',
            subtitle: 'Pay the seller directly when you collect',
          ),
          
          if (_selectedMethod == 'UPI') 
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _upiController,
                decoration: InputDecoration(
                  hintText: "Enter UPI ID (e.g. name@upi)",
                  hintStyle: AnnvaTextStyles.bodySmall,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AnnvaColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AnnvaColors.border),
                  ),
                ),
              ),
            ),
            
          if (_selectedMethod == 'Cash')
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AnnvaColors.cascadeFreshBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "You'll pay the total amount in cash when collecting your order.",
                style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11, color: AnnvaColors.cascadeFresh),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AnnvaColors.primary : AnnvaColors.border.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AnnvaColors.primary : AnnvaColors.border, width: 2),
              ),
              child: isSelected ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AnnvaColors.primary),
                ),
              ) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildPriceLockCredit() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AnnvaColors.cascadeFresh),
          const SizedBox(width: 8),
          Text("Price lock credit applied: -₹10", 
            style: AnnvaTextStyles.bodySmall.copyWith(color: AnnvaColors.cascadeFresh, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(double total) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AnnvaColors.backgroundCard,
        border: Border(top: BorderSide(color: AnnvaColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹${total.toStringAsFixed(0)}", style: AnnvaTextStyles.h1.copyWith(fontSize: 28)),
                Text("via $_selectedMethod", style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 180,
            height: 54,
            child: ElevatedButton(
              onPressed: _processMockPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnvaColors.primary,
                foregroundColor: AnnvaColors.primaryForeground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Pay & Rescue", style: AnnvaTextStyles.button.copyWith(fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Annva Logo placeholder (assuming it's a styled text or simple icon)
            Text("अन्न Annva", style: AnnvaTextStyles.h1.copyWith(color: AnnvaColors.background, fontSize: 40)),
            const SizedBox(height: 24),
            const _StaggeredPulseDots(),
            const SizedBox(height: 16),
            Text("Processing your rescue...", 
              style: AnnvaTextStyles.bodySmall.copyWith(color: AnnvaColors.background, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _StaggeredPulseDots extends StatefulWidget {
  const _StaggeredPulseDots();

  @override
  State<_StaggeredPulseDots> createState() => _StaggeredPulseDotsState();
}

class _StaggeredPulseDotsState extends State<_StaggeredPulseDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true));
    
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => FadeTransition(
        opacity: _controllers[index],
        child: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AnnvaColors.background),
        ),
      )),
    );
  }
}
