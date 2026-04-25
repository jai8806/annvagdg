import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';

part 'price_lock_provider.g.dart';

@riverpod
class PriceLockNotifier extends _$PriceLockNotifier {
  @override
  void build() {}

  Future<void> lockPrice(String listingId, double currentPrice) async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    final lockedUntil = DateTime.now().add(const Duration(minutes: 20));
    
    // Write lock to Firestore
    await FirebaseFirestore.instance
      .collection('listings')
      .doc(listingId)
      .update({
        'lockedPrice': currentPrice,
        'lockedUntil': Timestamp.fromDate(lockedUntil),
        'lockedByUserId': userId,
        'lockDepositPaid': 10.0,
      });
    
    // Record deposit transaction
    await FirebaseFirestore.instance
      .collection('lock_deposits')
      .add({
        'userId': userId,
        'listingId': listingId,
        'amount': 10.0,
        'lockedAt': FieldValue.serverTimestamp(),
        'lockedUntil': Timestamp.fromDate(lockedUntil),
        'status': 'active',  // 'redeemed' | 'forfeited_to_ngo'
      });
  }

  Future<void> redeemLock(String listingId) async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('lock_deposits')
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'status': 'redeemed'});
    }
  }

  Future<void> notifyWhenUnlocked(String listingId, String foodName, double price) async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('lock_watchers')
        .doc(listingId)
        .collection('users')
        .doc(userId)
        .set({
          'notified': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
