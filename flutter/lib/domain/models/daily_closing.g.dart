// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_closing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyClosingImpl _$$DailyClosingImplFromJson(
  Map<String, dynamic> json,
) => _$DailyClosingImpl(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  createdAt: const DateTimeConverter().fromJson(json['createdAt'] as String),
  exchangeRateSnapshot: (json['exchangeRateSnapshot'] as num).toDouble(),
  cashCountCordobas: Map<String, int>.from(json['cashCountCordobas'] as Map),
  cashCountDollars: Map<String, int>.from(json['cashCountDollars'] as Map),
  totalSystemCalculated: (json['totalSystemCalculated'] as num).toDouble(),
  totalPhysicalCounted: (json['totalPhysicalCounted'] as num).toDouble(),
  difference: (json['difference'] as num).toDouble(),
);

Map<String, dynamic> _$$DailyClosingImplToJson(_$DailyClosingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'exchangeRateSnapshot': instance.exchangeRateSnapshot,
      'cashCountCordobas': instance.cashCountCordobas,
      'cashCountDollars': instance.cashCountDollars,
      'totalSystemCalculated': instance.totalSystemCalculated,
      'totalPhysicalCounted': instance.totalPhysicalCounted,
      'difference': instance.difference,
    };
