// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PromoCodeModel _$PromoCodeModelFromJson(Map<String, dynamic> json) {
  return _PromoCodeModel.fromJson(json);
}

/// @nodoc
mixin _$PromoCodeModel {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String get discountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_value')
  double get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_purchase')
  double? get minPurchase => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_discount')
  double? get maxDiscount => throw _privateConstructorUsedError;
  @JsonKey(name: 'valid_from')
  DateTime? get validFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'valid_until')
  DateTime? get validUntil => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_uses')
  int? get maxUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'uses_count')
  int get usesCount => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PromoCodeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromoCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromoCodeModelCopyWith<PromoCodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoCodeModelCopyWith<$Res> {
  factory $PromoCodeModelCopyWith(
    PromoCodeModel value,
    $Res Function(PromoCodeModel) then,
  ) = _$PromoCodeModelCopyWithImpl<$Res, PromoCodeModel>;
  @useResult
  $Res call({
    String id,
    String code,
    String? description,
    @JsonKey(name: 'discount_type') String discountType,
    @JsonKey(name: 'discount_value') double discountValue,
    @JsonKey(name: 'min_purchase') double? minPurchase,
    @JsonKey(name: 'max_discount') double? maxDiscount,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_until') DateTime? validUntil,
    @JsonKey(name: 'max_uses') int? maxUses,
    @JsonKey(name: 'uses_count') int usesCount,
    bool active,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PromoCodeModelCopyWithImpl<$Res, $Val extends PromoCodeModel>
    implements $PromoCodeModelCopyWith<$Res> {
  _$PromoCodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromoCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minPurchase = freezed,
    Object? maxDiscount = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? maxUses = freezed,
    Object? usesCount = null,
    Object? active = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            discountType: null == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as String,
            discountValue: null == discountValue
                ? _value.discountValue
                : discountValue // ignore: cast_nullable_to_non_nullable
                      as double,
            minPurchase: freezed == minPurchase
                ? _value.minPurchase
                : minPurchase // ignore: cast_nullable_to_non_nullable
                      as double?,
            maxDiscount: freezed == maxDiscount
                ? _value.maxDiscount
                : maxDiscount // ignore: cast_nullable_to_non_nullable
                      as double?,
            validFrom: freezed == validFrom
                ? _value.validFrom
                : validFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            validUntil: freezed == validUntil
                ? _value.validUntil
                : validUntil // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            maxUses: freezed == maxUses
                ? _value.maxUses
                : maxUses // ignore: cast_nullable_to_non_nullable
                      as int?,
            usesCount: null == usesCount
                ? _value.usesCount
                : usesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromoCodeModelImplCopyWith<$Res>
    implements $PromoCodeModelCopyWith<$Res> {
  factory _$$PromoCodeModelImplCopyWith(
    _$PromoCodeModelImpl value,
    $Res Function(_$PromoCodeModelImpl) then,
  ) = __$$PromoCodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String? description,
    @JsonKey(name: 'discount_type') String discountType,
    @JsonKey(name: 'discount_value') double discountValue,
    @JsonKey(name: 'min_purchase') double? minPurchase,
    @JsonKey(name: 'max_discount') double? maxDiscount,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_until') DateTime? validUntil,
    @JsonKey(name: 'max_uses') int? maxUses,
    @JsonKey(name: 'uses_count') int usesCount,
    bool active,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$PromoCodeModelImplCopyWithImpl<$Res>
    extends _$PromoCodeModelCopyWithImpl<$Res, _$PromoCodeModelImpl>
    implements _$$PromoCodeModelImplCopyWith<$Res> {
  __$$PromoCodeModelImplCopyWithImpl(
    _$PromoCodeModelImpl _value,
    $Res Function(_$PromoCodeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromoCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = freezed,
    Object? discountType = null,
    Object? discountValue = null,
    Object? minPurchase = freezed,
    Object? maxDiscount = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? maxUses = freezed,
    Object? usesCount = null,
    Object? active = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PromoCodeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        discountType: null == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as String,
        discountValue: null == discountValue
            ? _value.discountValue
            : discountValue // ignore: cast_nullable_to_non_nullable
                  as double,
        minPurchase: freezed == minPurchase
            ? _value.minPurchase
            : minPurchase // ignore: cast_nullable_to_non_nullable
                  as double?,
        maxDiscount: freezed == maxDiscount
            ? _value.maxDiscount
            : maxDiscount // ignore: cast_nullable_to_non_nullable
                  as double?,
        validFrom: freezed == validFrom
            ? _value.validFrom
            : validFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        validUntil: freezed == validUntil
            ? _value.validUntil
            : validUntil // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        maxUses: freezed == maxUses
            ? _value.maxUses
            : maxUses // ignore: cast_nullable_to_non_nullable
                  as int?,
        usesCount: null == usesCount
            ? _value.usesCount
            : usesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoCodeModelImpl extends _PromoCodeModel {
  const _$PromoCodeModelImpl({
    required this.id,
    required this.code,
    this.description,
    @JsonKey(name: 'discount_type') this.discountType = 'percentage',
    @JsonKey(name: 'discount_value') required this.discountValue,
    @JsonKey(name: 'min_purchase') this.minPurchase,
    @JsonKey(name: 'max_discount') this.maxDiscount,
    @JsonKey(name: 'valid_from') this.validFrom,
    @JsonKey(name: 'valid_until') this.validUntil,
    @JsonKey(name: 'max_uses') this.maxUses,
    @JsonKey(name: 'uses_count') this.usesCount = 0,
    this.active = true,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _$PromoCodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoCodeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String? description;
  @override
  @JsonKey(name: 'discount_type')
  final String discountType;
  @override
  @JsonKey(name: 'discount_value')
  final double discountValue;
  @override
  @JsonKey(name: 'min_purchase')
  final double? minPurchase;
  @override
  @JsonKey(name: 'max_discount')
  final double? maxDiscount;
  @override
  @JsonKey(name: 'valid_from')
  final DateTime? validFrom;
  @override
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  @override
  @JsonKey(name: 'max_uses')
  final int? maxUses;
  @override
  @JsonKey(name: 'uses_count')
  final int usesCount;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PromoCodeModel(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minPurchase: $minPurchase, maxDiscount: $maxDiscount, validFrom: $validFrom, validUntil: $validUntil, maxUses: $maxUses, usesCount: $usesCount, active: $active, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoCodeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.minPurchase, minPurchase) ||
                other.minPurchase == minPurchase) &&
            (identical(other.maxDiscount, maxDiscount) ||
                other.maxDiscount == maxDiscount) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.usesCount, usesCount) ||
                other.usesCount == usesCount) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    description,
    discountType,
    discountValue,
    minPurchase,
    maxDiscount,
    validFrom,
    validUntil,
    maxUses,
    usesCount,
    active,
    createdAt,
  );

  /// Create a copy of PromoCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoCodeModelImplCopyWith<_$PromoCodeModelImpl> get copyWith =>
      __$$PromoCodeModelImplCopyWithImpl<_$PromoCodeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoCodeModelImplToJson(this);
  }
}

abstract class _PromoCodeModel extends PromoCodeModel {
  const factory _PromoCodeModel({
    required final String id,
    required final String code,
    final String? description,
    @JsonKey(name: 'discount_type') final String discountType,
    @JsonKey(name: 'discount_value') required final double discountValue,
    @JsonKey(name: 'min_purchase') final double? minPurchase,
    @JsonKey(name: 'max_discount') final double? maxDiscount,
    @JsonKey(name: 'valid_from') final DateTime? validFrom,
    @JsonKey(name: 'valid_until') final DateTime? validUntil,
    @JsonKey(name: 'max_uses') final int? maxUses,
    @JsonKey(name: 'uses_count') final int usesCount,
    final bool active,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$PromoCodeModelImpl;
  const _PromoCodeModel._() : super._();

  factory _PromoCodeModel.fromJson(Map<String, dynamic> json) =
      _$PromoCodeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String? get description;
  @override
  @JsonKey(name: 'discount_type')
  String get discountType;
  @override
  @JsonKey(name: 'discount_value')
  double get discountValue;
  @override
  @JsonKey(name: 'min_purchase')
  double? get minPurchase;
  @override
  @JsonKey(name: 'max_discount')
  double? get maxDiscount;
  @override
  @JsonKey(name: 'valid_from')
  DateTime? get validFrom;
  @override
  @JsonKey(name: 'valid_until')
  DateTime? get validUntil;
  @override
  @JsonKey(name: 'max_uses')
  int? get maxUses;
  @override
  @JsonKey(name: 'uses_count')
  int get usesCount;
  @override
  bool get active;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of PromoCodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromoCodeModelImplCopyWith<_$PromoCodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
