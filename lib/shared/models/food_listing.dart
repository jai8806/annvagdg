import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cascade_stage.dart';

part 'food_listing.freezed.dart';
part 'food_listing.g.dart';

// Helper to convert Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class FoodListing with _$FoodListing {
  const factory FoodListing({
    required String id,
    required String name,
    required String sellerId,
    required String sellerName,
    required String vertical,
    required String address,
    required List<String> diet,
    required double qtyKg,
    required int servings,
    required int originalPrice,
    required int currentPrice,
    required CascadeStage stage,
    @TimestampConverter() required DateTime expiresAt,
    required double lat,
    required double lng,
    required String imageUrl,
    @TimestampConverter() required DateTime createdAt,
    required bool isActive,
    double? lockedPrice,
    @TimestampConverter() DateTime? lockedUntil,
    String? lockedByUserId,
    @Default(10.0) double lockDepositPaid,
  }) = _FoodListing;
  const FoodListing._();

  factory FoodListing.fromJson(Map<String, dynamic> json) =>
      _$FoodListingFromJson(json);

  factory FoodListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // ensure ID is injected
    return FoodListing.fromJson(data);
  }

  String get sellerLabel => '$sellerName · $address';
  String get formattedPrice => '₹$currentPrice';
  String get formattedOriginalPrice => '₹$originalPrice';
  String get quantityLabel =>
      '${qtyKg.toStringAsFixed(1).replaceAll('.0', '')}kg • $servings servings';
}
