import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'price_lock_cleanup_provider.g.dart';

@riverpod
class PriceLockCleanup extends _$PriceLockCleanup {
  Timer? _timer;

  @override
  void build() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _cleanupExpiredLocks());
    ref.onDispose(() => _timer?.cancel());
  }

  Future<void> _cleanupExpiredLocks() async {
    final now = Timestamp.now();
    
    // 1. Find expired locks
    final snapshot = await FirebaseFirestore.instance
        .collection('listings')
        .where('lockedUntil', isLessThan: now)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final listingId = doc.id;
      final depositPaid = data['lockDepositPaid'] ?? 10.0;

      // 2. Clear lock from listing
      await doc.reference.update({
        'lockedByUserId': null,
        'lockedUntil': null,
        'lockedPrice': null,
      });

      // 3. Move deposit to NGO fund in Realtime Database
      final ngoRef = FirebaseDatabase.instance.ref('ngo_fund/total');
      await ngoRef.set(ServerValue.increment(depositPaid));

      // 4. Update deposit status
      final depSnapshot = await FirebaseFirestore.instance
          .collection('lock_deposits')
          .where('listingId', isEqualTo: listingId)
          .where('status', isEqualTo: 'active')
          .get();
      
      for (var depDoc in depSnapshot.docs) {
        await depDoc.reference.update({'status': 'forfeited_to_ngo'});
      }
    }
  }
}
