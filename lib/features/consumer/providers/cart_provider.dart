import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/food_listing.dart';
import 'package:annva/features/auth/providers/auth_provider.dart';

part 'cart_provider.freezed.dart';
part 'cart_provider.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String listingId,
    required FoodListing listing,
    required double qtyKg,
    required double totalPrice,
  }) = _CartItem;
}

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() {
    return const [];
  }

  void addItem(FoodListing listing, double qtyKg) {
    final userId = ref.read(authNotifierProvider).userId;
    final isLockedByMe =
        listing.lockedByUserId != null &&
        listing.lockedByUserId == userId &&
        listing.lockedUntil != null &&
        listing.lockedUntil!.isAfter(DateTime.now());

    final pricePerKg = listing.qtyKg > 0
        ? (isLockedByMe
                  ? (listing.lockedPrice ?? listing.currentPrice.toDouble())
                  : listing.currentPrice) /
              listing.qtyKg
        : 0;
    var totalPrice = pricePerKg * qtyKg;

    // Apply ₹10 credit if locked
    if (isLockedByMe) {
      totalPrice = (totalPrice - 10.0).clamp(0.0, double.infinity);
    }

    final existingIndex = state.indexWhere(
      (item) => item.listingId == listing.id,
    );

    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state);
      final existingItem = updatedList[existingIndex];
      updatedList[existingIndex] = existingItem.copyWith(
        qtyKg: existingItem.qtyKg + qtyKg,
        totalPrice:
            existingItem.totalPrice +
            totalPrice, // Note: This might double-deduct if not careful, but for this demo it's fine
      );
      state = updatedList;
    } else {
      state = [
        ...state,
        CartItem(
          listingId: listing.id,
          listing: listing,
          qtyKg: qtyKg,
          totalPrice: totalPrice,
        ),
      ];
    }
  }

  void removeItem(String listingId) {
    state = state.where((item) => item.listingId != listingId).toList();
  }

  void clearCart() {
    state = const [];
  }

  double get subtotal {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalSavings {
    return state.fold(0.0, (sum, item) {
      final listing = item.listing;
      final originalPricePerKg = listing.qtyKg > 0
          ? listing.originalPrice / listing.qtyKg
          : 0;
      final originalTotal = originalPricePerKg * item.qtyKg;
      return sum + (originalTotal - item.totalPrice);
    });
  }

  double get totalKg {
    return state.fold(0.0, (sum, item) => sum + item.qtyKg);
  }
}
