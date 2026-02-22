// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'guest_email')
  String? get guestEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_email')
  String? get customerEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_price')
  @PriceConverter()
  double get totalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  int get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String? get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_method')
  String? get shippingMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_info')
  Map<String, dynamic>? get contactInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_deducted')
  bool get stockDeducted => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<OrderItemModel>? get items => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
    OrderModel value,
    $Res Function(OrderModel) then,
  ) = _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'guest_email') String? guestEmail,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'total_price') @PriceConverter() double totalPrice,
    @JsonKey(name: 'total_amount') int totalAmount,
    String status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'shipping_method') String? shippingMethod,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'stock_deducted') bool stockDeducted,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<OrderItemModel>? items,
  });
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? guestEmail = freezed,
    Object? customerEmail = freezed,
    Object? totalPrice = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentMethod = freezed,
    Object? shippingMethod = freezed,
    Object? shippingAddress = freezed,
    Object? contactInfo = freezed,
    Object? stockDeducted = null,
    Object? createdAt = freezed,
    Object? items = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            guestEmail: freezed == guestEmail
                ? _value.guestEmail
                : guestEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerEmail: freezed == customerEmail
                ? _value.customerEmail
                : customerEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            shippingMethod: freezed == shippingMethod
                ? _value.shippingMethod
                : shippingMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            shippingAddress: freezed == shippingAddress
                ? _value.shippingAddress
                : shippingAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            contactInfo: freezed == contactInfo
                ? _value.contactInfo
                : contactInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            stockDeducted: null == stockDeducted
                ? _value.stockDeducted
                : stockDeducted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            items: freezed == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItemModel>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
    _$OrderModelImpl value,
    $Res Function(_$OrderModelImpl) then,
  ) = __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'guest_email') String? guestEmail,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'total_price') @PriceConverter() double totalPrice,
    @JsonKey(name: 'total_amount') int totalAmount,
    String status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'shipping_method') String? shippingMethod,
    @JsonKey(name: 'shipping_address') String? shippingAddress,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'stock_deducted') bool stockDeducted,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<OrderItemModel>? items,
  });
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
    _$OrderModelImpl _value,
    $Res Function(_$OrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? guestEmail = freezed,
    Object? customerEmail = freezed,
    Object? totalPrice = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentMethod = freezed,
    Object? shippingMethod = freezed,
    Object? shippingAddress = freezed,
    Object? contactInfo = freezed,
    Object? stockDeducted = null,
    Object? createdAt = freezed,
    Object? items = freezed,
  }) {
    return _then(
      _$OrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        guestEmail: freezed == guestEmail
            ? _value.guestEmail
            : guestEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerEmail: freezed == customerEmail
            ? _value.customerEmail
            : customerEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        shippingMethod: freezed == shippingMethod
            ? _value.shippingMethod
            : shippingMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        shippingAddress: freezed == shippingAddress
            ? _value.shippingAddress
            : shippingAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        contactInfo: freezed == contactInfo
            ? _value._contactInfo
            : contactInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        stockDeducted: null == stockDeducted
            ? _value.stockDeducted
            : stockDeducted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        items: freezed == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItemModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl({
    required this.id,
    @JsonKey(name: 'user_id') this.userId,
    @JsonKey(name: 'guest_email') this.guestEmail,
    @JsonKey(name: 'customer_email') this.customerEmail,
    @JsonKey(name: 'total_price') @PriceConverter() this.totalPrice = 0,
    @JsonKey(name: 'total_amount') this.totalAmount = 0,
    this.status = 'pending',
    @JsonKey(name: 'payment_method') this.paymentMethod,
    @JsonKey(name: 'shipping_method') this.shippingMethod,
    @JsonKey(name: 'shipping_address') this.shippingAddress,
    @JsonKey(name: 'contact_info') final Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'stock_deducted') this.stockDeducted = false,
    @JsonKey(name: 'created_at') this.createdAt,
    final List<OrderItemModel>? items,
  }) : _contactInfo = contactInfo,
       _items = items,
       super._();

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String? userId;
  @override
  @JsonKey(name: 'guest_email')
  final String? guestEmail;
  @override
  @JsonKey(name: 'customer_email')
  final String? customerEmail;
  @override
  @JsonKey(name: 'total_price')
  @PriceConverter()
  final double totalPrice;
  @override
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @override
  @JsonKey(name: 'shipping_method')
  final String? shippingMethod;
  @override
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  final Map<String, dynamic>? _contactInfo;
  @override
  @JsonKey(name: 'contact_info')
  Map<String, dynamic>? get contactInfo {
    final value = _contactInfo;
    if (value == null) return null;
    if (_contactInfo is EqualUnmodifiableMapView) return _contactInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'stock_deducted')
  final bool stockDeducted;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  final List<OrderItemModel>? _items;
  @override
  List<OrderItemModel>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, guestEmail: $guestEmail, customerEmail: $customerEmail, totalPrice: $totalPrice, totalAmount: $totalAmount, status: $status, paymentMethod: $paymentMethod, shippingMethod: $shippingMethod, shippingAddress: $shippingAddress, contactInfo: $contactInfo, stockDeducted: $stockDeducted, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.guestEmail, guestEmail) ||
                other.guestEmail == guestEmail) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.shippingMethod, shippingMethod) ||
                other.shippingMethod == shippingMethod) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            const DeepCollectionEquality().equals(
              other._contactInfo,
              _contactInfo,
            ) &&
            (identical(other.stockDeducted, stockDeducted) ||
                other.stockDeducted == stockDeducted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    guestEmail,
    customerEmail,
    totalPrice,
    totalAmount,
    status,
    paymentMethod,
    shippingMethod,
    shippingAddress,
    const DeepCollectionEquality().hash(_contactInfo),
    stockDeducted,
    createdAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(this);
  }
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel({
    required final String id,
    @JsonKey(name: 'user_id') final String? userId,
    @JsonKey(name: 'guest_email') final String? guestEmail,
    @JsonKey(name: 'customer_email') final String? customerEmail,
    @JsonKey(name: 'total_price') @PriceConverter() final double totalPrice,
    @JsonKey(name: 'total_amount') final int totalAmount,
    final String status,
    @JsonKey(name: 'payment_method') final String? paymentMethod,
    @JsonKey(name: 'shipping_method') final String? shippingMethod,
    @JsonKey(name: 'shipping_address') final String? shippingAddress,
    @JsonKey(name: 'contact_info') final Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'stock_deducted') final bool stockDeducted,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final List<OrderItemModel>? items,
  }) = _$OrderModelImpl;
  const _OrderModel._() : super._();

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String? get userId;
  @override
  @JsonKey(name: 'guest_email')
  String? get guestEmail;
  @override
  @JsonKey(name: 'customer_email')
  String? get customerEmail;
  @override
  @JsonKey(name: 'total_price')
  @PriceConverter()
  double get totalPrice;
  @override
  @JsonKey(name: 'total_amount')
  int get totalAmount;
  @override
  String get status;
  @override
  @JsonKey(name: 'payment_method')
  String? get paymentMethod;
  @override
  @JsonKey(name: 'shipping_method')
  String? get shippingMethod;
  @override
  @JsonKey(name: 'shipping_address')
  String? get shippingAddress;
  @override
  @JsonKey(name: 'contact_info')
  Map<String, dynamic>? get contactInfo;
  @override
  @JsonKey(name: 'stock_deducted')
  bool get stockDeducted;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  List<OrderItemModel>? get items;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
