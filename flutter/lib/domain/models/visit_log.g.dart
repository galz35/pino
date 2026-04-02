// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisitLogImpl _$$VisitLogImplFromJson(Map<String, dynamic> json) =>
    _$VisitLogImpl(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      storeId: json['storeId'] as String,
      vendorId: json['vendorId'] as String,
      date: const DateTimeConverter().fromJson(json['date'] as String),
      status: json['status'] as String,
      orderId: json['orderId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$VisitLogImplToJson(_$VisitLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'storeId': instance.storeId,
      'vendorId': instance.vendorId,
      'date': const DateTimeConverter().toJson(instance.date),
      'status': instance.status,
      'orderId': instance.orderId,
      'notes': instance.notes,
    };
