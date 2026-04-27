import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:annva/core/theme/annva_colors.dart';
import 'package:annva/core/theme/annva_text_styles.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authNotifierProvider).userId;

    return Scaffold(
      backgroundColor: AnnvaColors.background,
      appBar: AppBar(
        backgroundColor: AnnvaColors.background,
        elevation: 0,
        title: Text('My Rescues', style: AnnvaTextStyles.h1),
        centerTitle: false,
      ),
      body: userId == null
          ? const Center(child: Text('Please login to see your rescues'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('consumerId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _OrderHistoryTile(order: order);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: AnnvaColors.border),
            const SizedBox(height: 24),
            Text('No rescues yet.', style: AnnvaTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Browse the live cascade to make your first rescue.',
              textAlign: TextAlign.center,
              style: AnnvaTextStyles.bodySmall,
            ),
            const SizedBox(height: 32),
            // We could add a button here to navigate back to browse, 
            // but since it's a tab, user can just switch tabs.
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderHistoryTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final createdAt = (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final items = order['items'] as List;
    final foodName = items.isNotEmpty ? items.first['name'] : 'Food Rescue';
    final sellerName = order['sellerName'] ?? 'Unknown Seller';
    final address = order['sellerAddress'] ?? '';
    final totalAmount = order['totalAmount'] ?? 0;
    final totalKg = order['totalKg'] ?? 0;
    final pickupCode = order['pickupCode'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnnvaColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnnvaColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🍱', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(foodName, 
                            style: AnnvaTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    Text('$sellerName · $address', 
                      style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${DateFormat('MMM d').format(createdAt)} · ₹${totalAmount.toStringAsFixed(0)} · ${totalKg.toStringAsFixed(1)}kg",
                      style: AnnvaTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AnnvaColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Code: $pickupCode', style: AnnvaTextStyles.mono),
              if (status == 'confirmed')
                Text('Scan at counter →', style: AnnvaTextStyles.label.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'confirmed':
        bgColor = AnnvaColors.ochre.withOpacity(0.1);
        textColor = AnnvaColors.ochreDeep;
        label = 'SECURED';
        break;
      case 'picked_up':
        bgColor = AnnvaColors.cascadeFreshBg;
        textColor = AnnvaColors.cascadeFresh;
        label = 'RESCUED ✓';
        break;
      case 'expired':
        bgColor = AnnvaColors.muted.withOpacity(0.1);
        textColor = AnnvaColors.muted;
        label = 'EXPIRED';
        break;
      default:
        bgColor = AnnvaColors.border.withOpacity(0.1);
        textColor = AnnvaColors.muted;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AnnvaTextStyles.label.copyWith(
          fontSize: 9,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
