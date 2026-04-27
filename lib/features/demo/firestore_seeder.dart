import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../shared/models/cascade_stage.dart';
import '../../shared/models/food_listing.dart';

class FirestoreSeeder {
  static Future<void> seedListings() async {
    final firestore = FirebaseFirestore.instance;
    final listingsRef = firestore.collection('listings');
    final now = DateTime.now();

    final mockListings = [
      FoodListing(
        id: 'L01',
        name: '[LIVE] Fresh produce mix',
        sellerId: 's5',
        sellerName: 'Reliance Fresh',
        vertical: 'Kirana',
        address: 'HSR Layout',
        diet: const ['veg'],
        qtyKg: 25,
        servings: 100,
        originalPrice: 5000,
        currentPrice: 4250, // 85% of price
        stage: CascadeStage.fresh,
        expiresAt: now.add(const Duration(hours: 6)),
        lat: 12.9116,
        lng: 77.6389,
        imageUrl: '🥦',
        createdAt: now.subtract(const Duration(minutes: 10)), // 0-1h elapsed
        isActive: true,
        lockedByUserId: 'mock_0000000000',
        lockedPrice: 4250,
        lockedUntil: now.add(const Duration(minutes: 15)),
        lockDepositPaid: 10.0,
      ),
      FoodListing(
        id: 'L02',
        name: '[LIVE] Cold-pressed juice',
        sellerId: 's4',
        sellerName: 'BBK Bakery',
        vertical: 'Bakery',
        address: 'Koramangala',
        diet: const ['veg'],
        qtyKg: 3,
        servings: 20,
        originalPrice: 3000,
        currentPrice: 2100, // 70% of price
        stage: CascadeStage.goodDeal,
        expiresAt: now.add(const Duration(hours: 5)),
        lat: 12.9352,
        lng: 77.6245,
        imageUrl: '🥤',
        createdAt: now.subtract(const Duration(minutes: 90)), // 1-2h elapsed
        isActive: true,
        lockedByUserId: 'other_user',
        lockedPrice: 2100,
        lockedUntil: now.add(const Duration(minutes: 12)),
        lockDepositPaid: 10.0,
      ),
      FoodListing(
        id: 'L03',
        name: '[LIVE] Veg thali',
        sellerId: 's3',
        sellerName: 'Nandhini Deluxe',
        vertical: 'Restaurant',
        address: 'Jayanagar',
        diet: const ['veg'],
        qtyKg: 15,
        servings: 60,
        originalPrice: 6000,
        currentPrice: 3000, // 50% of price
        stage: CascadeStage.hotDeal,
        expiresAt: now.add(const Duration(hours: 4)),
        lat: 12.9250,
        lng: 77.5938,
        imageUrl: '🍱',
        createdAt: now.subtract(const Duration(minutes: 150)), // 2-3h elapsed
        isActive: true,
      ),
      FoodListing(
        id: 'L04',
        name: '[LIVE] Butter croissants',
        sellerId: 's2',
        sellerName: 'Third Wave Coffee',
        vertical: 'Bakery',
        address: 'Indiranagar',
        diet: const ['veg'],
        qtyKg: 3,
        servings: 24,
        originalPrice: 1800,
        currentPrice: 450, // 25% of price
        stage: CascadeStage.lastCall,
        expiresAt: now.add(const Duration(hours: 1)),
        lat: 12.9784,
        lng: 77.6408,
        imageUrl: '🥐',
        createdAt: now.subtract(const Duration(minutes: 195)), // 3-3.5h elapsed
        isActive: true,
      ),
      FoodListing(
        id: 'L05',
        name: '[LIVE] Wedding biryani',
        sellerId: 's6',
        sellerName: 'Taj West End',
        vertical: 'Event',
        address: 'MG Road',
        diet: const ['veg'],
        qtyKg: 40,
        servings: 160,
        originalPrice: 20000,
        currentPrice: 0, // FREE
        stage: CascadeStage.ngo,
        expiresAt: now.add(const Duration(minutes: 30)),
        lat: 12.9716,
        lng: 77.5946,
        imageUrl: '🍛',
        createdAt: now.subtract(const Duration(minutes: 225)), // 3.5-4h elapsed
        isActive: true,
      ),
    ];

    // Delete existing
    final existing = await listingsRef.get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    // Insert new
    for (var listing in mockListings) {
      // Using .set with custom ID so we don't get duplicates if seeded multiple times
      await listingsRef.doc(listing.id).set(listing.toJson());
    }
  }
}
