import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/food_listing.dart';
import '../repositories/listings_repository.dart';

part 'listings_provider.g.dart';

@riverpod
Stream<List<FoodListing>> activeListings(ActiveListingsRef ref) {
  return ref.watch(listingsRepositoryProvider).watchActiveListings();
}
