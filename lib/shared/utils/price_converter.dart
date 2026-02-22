import 'package:freezed_annotation/freezed_annotation.dart';

class PriceConverter implements JsonConverter<double, num?> {
  const PriceConverter();

  @override
  double fromJson(num? value) => (value?.toDouble() ?? 0) / 100;

  @override
  num toJson(double value) => (value * 100).round();
}

