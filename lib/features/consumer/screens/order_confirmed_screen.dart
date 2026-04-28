import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:annva/core/theme/annva_colors.dart';
import 'package:annva/core/theme/annva_text_styles.dart';

class OrderConfirmedScreen extends ConsumerWidget {
  final String orderId;

  const OrderConfirmedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AnnvaColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final pickupCode = orderData['pickupCode'] as String;
          final sellerName = orderData['sellerName'] as String;
          final address = orderData['sellerAddress'] as String;
          final totalAmount = orderData['totalAmount'] as num;
          final totalKg = orderData['totalKg'] as num;
          final paymentMethod = orderData['paymentMethod'] as String;
          final lat = orderData['lat'] as double;
          final lng = orderData['lng'] as double;
          final itemsCount = (orderData['items'] as List).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPickupPass(
                  context,
                  pickupCode: pickupCode,
                  orderId: orderId,
                  sellerName: sellerName,
                  address: address,
                  itemsCount: itemsCount,
                  totalKg: totalKg,
                  totalAmount: totalAmount,
                  method: paymentMethod,
                ),
                const SizedBox(height: 32),
                _buildActionButtons(context, lat: lat, lng: lng, pickupCode: pickupCode, totalKg: totalKg),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/consumer'),
                  child: Text('Back to browsing', style: AnnvaTextStyles.bodySmall.copyWith(color: AnnvaColors.muted)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AnnvaColors.cascadeFresh,
              ),
              child: const Icon(Icons.check, size: 40, color: Colors.white),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut, begin: const Offset(0, 0), end: const Offset(1, 1)),
            
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AnnvaColors.cascadeFresh, width: 2),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(duration: 1200.ms, begin: const Offset(0.6, 0.6), end: const Offset(1.4, 1.4))
            .fadeOut(duration: 1200.ms),
          ],
        ),
        const SizedBox(height: 20),
        Text('Order Confirmed!', style: AnnvaTextStyles.h1),
        const SizedBox(height: 4),
        Text('Your food rescue is secured.', style: AnnvaTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildPickupPass(
    BuildContext context, {
    required String pickupCode,
    required String orderId,
    required String sellerName,
    required String address,
    required int itemsCount,
    required num totalKg,
    required num totalAmount,
    required String method,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AnnvaColors.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AnnvaColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('अन्नवा Annva', style: AnnvaTextStyles.h3.copyWith(color: AnnvaColors.background, fontSize: 18)),
                Text('PICKUP PASS', style: AnnvaTextStyles.label.copyWith(color: AnnvaColors.background.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(sellerName, style: AnnvaTextStyles.h2),
                Text(address, style: AnnvaTextStyles.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _buildDashedDivider(),
                const SizedBox(height: 20),
                Text('SHOW THIS CODE AT THE COUNTER', style: AnnvaTextStyles.label),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      pickupCode,
                      style: AnnvaTextStyles.display.copyWith(fontSize: 48, letterSpacing: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: 'ANNVA-$pickupCode-$orderId',
                  version: QrVersions.auto,
                  size: 140.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AnnvaColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AnnvaColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDashedDivider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPassDetail('ITEMS', '$itemsCount items · ${totalKg.toStringAsFixed(1)}kg'),
                    _buildPassDetail('PAID', '₹${totalAmount.toStringAsFixed(0)} via $method'),
                    _buildPassDetail('WINDOW', '60 mins'), // Simplified for mock
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 48,
            color: AnnvaColors.backgroundSecondary.withValues(alpha: 0.3),
            child: Center(
              child: Text(
                '🌱 You\'re rescuing ${totalKg.toStringAsFixed(1)}kg from waste today',
                style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11, color: AnnvaColors.cascadeFresh, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AnnvaTextStyles.label.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AnnvaColors.primary)),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(30, (index) => Expanded(
        child: Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: AnnvaColors.border,
        ),
      )),
    );
  }

  Widget _buildActionButtons(BuildContext context, {required double lat, required double lng, required String pickupCode, required num totalKg}) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng")),
            icon: const Icon(Icons.location_on_outlined, size: 20),
            label: const Text('Navigate to Restaurant'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AnnvaColors.primary,
              side: const BorderSide(color: AnnvaColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Share.share(
                "I just rescued ${totalKg.toStringAsFixed(1)}kg of food with Annva! 🌱\nPickup code: $pickupCode\nDownload Annva: annva.in",
              );
            },
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('Share pickup pass'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AnnvaColors.primary,
              side: const BorderSide(color: AnnvaColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
