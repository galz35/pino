import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone.freezed.dart';
part 'zone.g.dart';

@freezed
abstract class Zone with _$Zone {
  const factory Zone({
    required String id,
    required String name,
    String? visitDay,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}

@freezed
abstract class SubZone with _$SubZone {
  const factory SubZone({
    required String id,
    required String name,
    required String zoneId,
    required List<int> deliveryDays, // 1=Mon, 7=Sun
  }) = _SubZone;

  factory SubZone.fromJson(Map<String, dynamic> json) =>
      _$SubZoneFromJson(json);
}
