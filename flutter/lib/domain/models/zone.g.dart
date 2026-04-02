// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ZoneImpl _$$ZoneImplFromJson(Map<String, dynamic> json) => _$ZoneImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  visitDay: json['visitDay'] as String?,
);

Map<String, dynamic> _$$ZoneImplToJson(_$ZoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'visitDay': instance.visitDay,
    };

_$SubZoneImpl _$$SubZoneImplFromJson(Map<String, dynamic> json) =>
    _$SubZoneImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      zoneId: json['zoneId'] as String,
      deliveryDays: (json['deliveryDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$SubZoneImplToJson(_$SubZoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'zoneId': instance.zoneId,
      'deliveryDays': instance.deliveryDays,
    };
