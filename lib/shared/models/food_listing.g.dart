// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodListingImpl _$$FoodListingImplFromJson(Map<String, dynamic> json) =>
    _$FoodListingImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      vertical: json['vertical'] as String,
      address: json['address'] as String,
      diet: (json['diet'] as List<dynamic>).map((e) => e as String).toList(),
      qtyKg: (json['qtyKg'] as num).toDouble(),
      servings: (json['servings'] as num).toInt(),
      originalPrice: (json['originalPrice'] as num).toInt(),
      currentPrice: (json['currentPrice'] as num).toInt(),
      stage: $enumDecode(_$CascadeStageEnumMap, json['stage']),
      expiresAt: const TimestampConverter().fromJson(
        json['expiresAt'] as Timestamp,
      ),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      isActive: json['isActive'] as bool,
      lockedPrice: (json['lockedPrice'] as num?)?.toDouble(),
      lockedUntil: json['lockedUntil'] == null
          ? null
          : const TimestampConverter().fromJson(
              json['lockedUntil'] as Timestamp,
            ),
      lockedByUserId: json['lockedByUserId'] as String?,
      lockDepositPaid: (json['lockDepositPaid'] as num?)?.toDouble() ?? 10.0,
    );

Map<String, dynamic> _$$FoodListingImplToJson(_$FoodListingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'vertical': instance.vertical,
      'address': instance.address,
      'diet': instance.diet,
      'qtyKg': instance.qtyKg,
      'servings': instance.servings,
      'originalPrice': instance.originalPrice,
      'currentPrice': instance.currentPrice,
      'stage': _$CascadeStageEnumMap[instance.stage]!,
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
      'lat': instance.lat,
      'lng': instance.lng,
      'imageUrl': instance.imageUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
      'lockedPrice': instance.lockedPrice,
      'lockedUntil': instance.lockedUntil == null
          ? null
          : const TimestampConverter().toJson(instance.lockedUntil!),
      'lockedByUserId': instance.lockedByUserId,
      'lockDepositPaid': instance.lockDepositPaid,
    };

const _$CascadeStageEnumMap = {
  CascadeStage.fresh: 'fresh',
  CascadeStage.goodDeal: 'good_deal',
  CascadeStage.hotDeal: 'hot_deal',
  CascadeStage.lastCall: 'last_call',
  CascadeStage.ngo: 'ngo',
};
