// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FoodListing _$FoodListingFromJson(Map<String, dynamic> json) {
  return _FoodListing.fromJson(json);
}

/// @nodoc
mixin _$FoodListing {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get sellerName => throw _privateConstructorUsedError;
  String get vertical => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  List<String> get diet => throw _privateConstructorUsedError;
  double get qtyKg => throw _privateConstructorUsedError;
  int get servings => throw _privateConstructorUsedError;
  int get originalPrice => throw _privateConstructorUsedError;
  int get currentPrice => throw _privateConstructorUsedError;
  CascadeStage get stage => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get expiresAt => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  double? get lockedPrice => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lockedUntil => throw _privateConstructorUsedError;
  String? get lockedByUserId => throw _privateConstructorUsedError;
  double get lockDepositPaid => throw _privateConstructorUsedError;

  /// Serializes this FoodListing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FoodListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodListingCopyWith<FoodListing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodListingCopyWith<$Res> {
  factory $FoodListingCopyWith(
    FoodListing value,
    $Res Function(FoodListing) then,
  ) = _$FoodListingCopyWithImpl<$Res, FoodListing>;
  @useResult
  $Res call({
    String id,
    String name,
    String sellerId,
    String sellerName,
    String vertical,
    String address,
    List<String> diet,
    double qtyKg,
    int servings,
    int originalPrice,
    int currentPrice,
    CascadeStage stage,
    @TimestampConverter() DateTime expiresAt,
    double lat,
    double lng,
    String imageUrl,
    @TimestampConverter() DateTime createdAt,
    bool isActive,
    double? lockedPrice,
    @TimestampConverter() DateTime? lockedUntil,
    String? lockedByUserId,
    double lockDepositPaid,
  });
}

/// @nodoc
class _$FoodListingCopyWithImpl<$Res, $Val extends FoodListing>
    implements $FoodListingCopyWith<$Res> {
  _$FoodListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? vertical = null,
    Object? address = null,
    Object? diet = null,
    Object? qtyKg = null,
    Object? servings = null,
    Object? originalPrice = null,
    Object? currentPrice = null,
    Object? stage = null,
    Object? expiresAt = null,
    Object? lat = null,
    Object? lng = null,
    Object? imageUrl = null,
    Object? createdAt = null,
    Object? isActive = null,
    Object? lockedPrice = freezed,
    Object? lockedUntil = freezed,
    Object? lockedByUserId = freezed,
    Object? lockDepositPaid = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sellerId: null == sellerId
                ? _value.sellerId
                : sellerId // ignore: cast_nullable_to_non_nullable
                      as String,
            sellerName: null == sellerName
                ? _value.sellerName
                : sellerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vertical: null == vertical
                ? _value.vertical
                : vertical // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            diet: null == diet
                ? _value.diet
                : diet // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            qtyKg: null == qtyKg
                ? _value.qtyKg
                : qtyKg // ignore: cast_nullable_to_non_nullable
                      as double,
            servings: null == servings
                ? _value.servings
                : servings // ignore: cast_nullable_to_non_nullable
                      as int,
            originalPrice: null == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPrice: null == currentPrice
                ? _value.currentPrice
                : currentPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as CascadeStage,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            lockedPrice: freezed == lockedPrice
                ? _value.lockedPrice
                : lockedPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            lockedUntil: freezed == lockedUntil
                ? _value.lockedUntil
                : lockedUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lockedByUserId: freezed == lockedByUserId
                ? _value.lockedByUserId
                : lockedByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lockDepositPaid: null == lockDepositPaid
                ? _value.lockDepositPaid
                : lockDepositPaid // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FoodListingImplCopyWith<$Res>
    implements $FoodListingCopyWith<$Res> {
  factory _$$FoodListingImplCopyWith(
    _$FoodListingImpl value,
    $Res Function(_$FoodListingImpl) then,
  ) = __$$FoodListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String sellerId,
    String sellerName,
    String vertical,
    String address,
    List<String> diet,
    double qtyKg,
    int servings,
    int originalPrice,
    int currentPrice,
    CascadeStage stage,
    @TimestampConverter() DateTime expiresAt,
    double lat,
    double lng,
    String imageUrl,
    @TimestampConverter() DateTime createdAt,
    bool isActive,
    double? lockedPrice,
    @TimestampConverter() DateTime? lockedUntil,
    String? lockedByUserId,
    double lockDepositPaid,
  });
}

/// @nodoc
class __$$FoodListingImplCopyWithImpl<$Res>
    extends _$FoodListingCopyWithImpl<$Res, _$FoodListingImpl>
    implements _$$FoodListingImplCopyWith<$Res> {
  __$$FoodListingImplCopyWithImpl(
    _$FoodListingImpl _value,
    $Res Function(_$FoodListingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FoodListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sellerId = null,
    Object? sellerName = null,
    Object? vertical = null,
    Object? address = null,
    Object? diet = null,
    Object? qtyKg = null,
    Object? servings = null,
    Object? originalPrice = null,
    Object? currentPrice = null,
    Object? stage = null,
    Object? expiresAt = null,
    Object? lat = null,
    Object? lng = null,
    Object? imageUrl = null,
    Object? createdAt = null,
    Object? isActive = null,
    Object? lockedPrice = freezed,
    Object? lockedUntil = freezed,
    Object? lockedByUserId = freezed,
    Object? lockDepositPaid = null,
  }) {
    return _then(
      _$FoodListingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sellerId: null == sellerId
            ? _value.sellerId
            : sellerId // ignore: cast_nullable_to_non_nullable
                  as String,
        sellerName: null == sellerName
            ? _value.sellerName
            : sellerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vertical: null == vertical
            ? _value.vertical
            : vertical // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        diet: null == diet
            ? _value._diet
            : diet // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        qtyKg: null == qtyKg
            ? _value.qtyKg
            : qtyKg // ignore: cast_nullable_to_non_nullable
                  as double,
        servings: null == servings
            ? _value.servings
            : servings // ignore: cast_nullable_to_non_nullable
                  as int,
        originalPrice: null == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPrice: null == currentPrice
            ? _value.currentPrice
            : currentPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as CascadeStage,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        lockedPrice: freezed == lockedPrice
            ? _value.lockedPrice
            : lockedPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        lockedUntil: freezed == lockedUntil
            ? _value.lockedUntil
            : lockedUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lockedByUserId: freezed == lockedByUserId
            ? _value.lockedByUserId
            : lockedByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lockDepositPaid: null == lockDepositPaid
            ? _value.lockDepositPaid
            : lockDepositPaid // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodListingImpl extends _FoodListing {
  const _$FoodListingImpl({
    required this.id,
    required this.name,
    required this.sellerId,
    required this.sellerName,
    required this.vertical,
    required this.address,
    required final List<String> diet,
    required this.qtyKg,
    required this.servings,
    required this.originalPrice,
    required this.currentPrice,
    required this.stage,
    @TimestampConverter() required this.expiresAt,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    @TimestampConverter() required this.createdAt,
    required this.isActive,
    this.lockedPrice,
    @TimestampConverter() this.lockedUntil,
    this.lockedByUserId,
    this.lockDepositPaid = 10.0,
  }) : _diet = diet,
       super._();

  factory _$FoodListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodListingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String sellerId;
  @override
  final String sellerName;
  @override
  final String vertical;
  @override
  final String address;
  final List<String> _diet;
  @override
  List<String> get diet {
    if (_diet is EqualUnmodifiableListView) return _diet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diet);
  }

  @override
  final double qtyKg;
  @override
  final int servings;
  @override
  final int originalPrice;
  @override
  final int currentPrice;
  @override
  final CascadeStage stage;
  @override
  @TimestampConverter()
  final DateTime expiresAt;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String imageUrl;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final bool isActive;
  @override
  final double? lockedPrice;
  @override
  @TimestampConverter()
  final DateTime? lockedUntil;
  @override
  final String? lockedByUserId;
  @override
  @JsonKey()
  final double lockDepositPaid;

  @override
  String toString() {
    return 'FoodListing(id: $id, name: $name, sellerId: $sellerId, sellerName: $sellerName, vertical: $vertical, address: $address, diet: $diet, qtyKg: $qtyKg, servings: $servings, originalPrice: $originalPrice, currentPrice: $currentPrice, stage: $stage, expiresAt: $expiresAt, lat: $lat, lng: $lng, imageUrl: $imageUrl, createdAt: $createdAt, isActive: $isActive, lockedPrice: $lockedPrice, lockedUntil: $lockedUntil, lockedByUserId: $lockedByUserId, lockDepositPaid: $lockDepositPaid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodListingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.vertical, vertical) ||
                other.vertical == vertical) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality().equals(other._diet, _diet) &&
            (identical(other.qtyKg, qtyKg) || other.qtyKg == qtyKg) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lockedPrice, lockedPrice) ||
                other.lockedPrice == lockedPrice) &&
            (identical(other.lockedUntil, lockedUntil) ||
                other.lockedUntil == lockedUntil) &&
            (identical(other.lockedByUserId, lockedByUserId) ||
                other.lockedByUserId == lockedByUserId) &&
            (identical(other.lockDepositPaid, lockDepositPaid) ||
                other.lockDepositPaid == lockDepositPaid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    sellerId,
    sellerName,
    vertical,
    address,
    const DeepCollectionEquality().hash(_diet),
    qtyKg,
    servings,
    originalPrice,
    currentPrice,
    stage,
    expiresAt,
    lat,
    lng,
    imageUrl,
    createdAt,
    isActive,
    lockedPrice,
    lockedUntil,
    lockedByUserId,
    lockDepositPaid,
  ]);

  /// Create a copy of FoodListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodListingImplCopyWith<_$FoodListingImpl> get copyWith =>
      __$$FoodListingImplCopyWithImpl<_$FoodListingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodListingImplToJson(this);
  }
}

abstract class _FoodListing extends FoodListing {
  const factory _FoodListing({
    required final String id,
    required final String name,
    required final String sellerId,
    required final String sellerName,
    required final String vertical,
    required final String address,
    required final List<String> diet,
    required final double qtyKg,
    required final int servings,
    required final int originalPrice,
    required final int currentPrice,
    required final CascadeStage stage,
    @TimestampConverter() required final DateTime expiresAt,
    required final double lat,
    required final double lng,
    required final String imageUrl,
    @TimestampConverter() required final DateTime createdAt,
    required final bool isActive,
    final double? lockedPrice,
    @TimestampConverter() final DateTime? lockedUntil,
    final String? lockedByUserId,
    final double lockDepositPaid,
  }) = _$FoodListingImpl;
  const _FoodListing._() : super._();

  factory _FoodListing.fromJson(Map<String, dynamic> json) =
      _$FoodListingImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get sellerId;
  @override
  String get sellerName;
  @override
  String get vertical;
  @override
  String get address;
  @override
  List<String> get diet;
  @override
  double get qtyKg;
  @override
  int get servings;
  @override
  int get originalPrice;
  @override
  int get currentPrice;
  @override
  CascadeStage get stage;
  @override
  @TimestampConverter()
  DateTime get expiresAt;
  @override
  double get lat;
  @override
  double get lng;
  @override
  String get imageUrl;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  bool get isActive;
  @override
  double? get lockedPrice;
  @override
  @TimestampConverter()
  DateTime? get lockedUntil;
  @override
  String? get lockedByUserId;
  @override
  double get lockDepositPaid;

  /// Create a copy of FoodListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodListingImplCopyWith<_$FoodListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
