import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'daily_closing.freezed.dart';
part 'daily_closing.g.dart';

@freezed
class DailyClosing with _$DailyClosing {
  const factory DailyClosing({
    required String id,
    required String driverId,
    @DateTimeConverter() required DateTime createdAt,
    required double exchangeRateSnapshot, // Tasa del día congelada
    required Map<String, int> cashCountCordobas, // {'1000': 5, '500': 2...}
    required Map<String, int> cashCountDollars, // {'100': 1, '20': 5...}
    required double totalSystemCalculated,
    required double totalPhysicalCounted,
    required double difference, // Faltante o sobrante
  }) = _DailyClosing;

  factory DailyClosing.fromJson(Map<String, dynamic> json) =>
      _$DailyClosingFromJson(json);
}
