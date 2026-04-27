import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_listing.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(FirebaseFirestore.instance);
});

class ListingsRepository {
  final FirebaseFirestore _firestore;

  ListingsRepository(this._firestore);

  Stream<List<FoodListing>> watchActiveListings() {
    return _firestore
        .collection('listings')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final docs = snapshot.docs
              .map((doc) => FoodListing.fromFirestore(doc))
              .where((listing) => listing.expiresAt.isAfter(now))
              .toList();
          docs.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
          return docs;
        });
  }

  Stream<FoodListing> watchListing(String id) {
    return _firestore
        .collection('listings')
        .doc(id)
        .snapshots()
        .map((doc) => FoodListing.fromFirestore(doc));
  }
}
