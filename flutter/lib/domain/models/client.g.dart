// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientLocationImpl _$$ClientLocationImplFromJson(Map<String, dynamic> json) =>
    _$ClientLocationImpl(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$$ClientLocationImplToJson(
  _$ClientLocationImpl instance,
) => <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
  id: json['id'] as String,
  storeId: json['storeId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  zoneId: json['zoneId'] as String,
  subZoneId: json['subZoneId'] as String,
  assignedPreventaId: json['assignedPreventaId'] as String,
  creditLimit: (json['creditLimit'] as num).toDouble(),
  currentDebt: (json['currentDebt'] as num).toDouble(),
  sectorId: json['sectorId'] as String?,
  location: json['location'] == null
      ? null
      : ClientLocation.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'zoneId': instance.zoneId,
      'subZoneId': instance.subZoneId,
      'assignedPreventaId': instance.assignedPreventaId,
      'creditLimit': instance.creditLimit,
      'currentDebt': instance.currentDebt,
      'sectorId': instance.sectorId,
      'location': instance.location,
    };
