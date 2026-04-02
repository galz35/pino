import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@freezed
class ClientLocation with _$ClientLocation {
  const factory ClientLocation({required double lat, required double lng}) =
      _ClientLocation;

  factory ClientLocation.fromJson(Map<String, dynamic> json) =>
      _$ClientLocationFromJson(json);
}

@freezed
class Client with _$Client {
  const factory Client({
    required String id,
    required String storeId,
    required String name,
    required String phone,
    required String address,
    required String zoneId,
    required String subZoneId,
    required String assignedPreventaId,
    required double creditLimit,
    required double currentDebt,
    String? sectorId,
    ClientLocation? location,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
