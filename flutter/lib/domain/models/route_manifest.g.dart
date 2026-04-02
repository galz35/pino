// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryStopImpl _$$DeliveryStopImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryStopImpl(
      id: json['id'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      isVisited: json['isVisited'] as bool,
      visitedAt: const NullableDateTimeConverter().fromJson(
        json['visitedAt'] as String?,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DeliveryStopImplToJson(_$DeliveryStopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client': instance.client,
      'order': instance.order,
      'isVisited': instance.isVisited,
      'visitedAt': const NullableDateTimeConverter().toJson(instance.visitedAt),
      'runtimeType': instance.$type,
    };

_$CollectionStopImpl _$$CollectionStopImplFromJson(Map<String, dynamic> json) =>
    _$CollectionStopImpl(
      id: json['id'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      amountToCollect: (json['amountToCollect'] as num).toDouble(),
      isVisited: json['isVisited'] as bool,
      visitedAt: const NullableDateTimeConverter().fromJson(
        json['visitedAt'] as String?,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CollectionStopImplToJson(
  _$CollectionStopImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'client': instance.client,
  'amountToCollect': instance.amountToCollect,
  'isVisited': instance.isVisited,
  'visitedAt': const NullableDateTimeConverter().toJson(instance.visitedAt),
  'runtimeType': instance.$type,
};

_$CombinedStopImpl _$$CombinedStopImplFromJson(Map<String, dynamic> json) =>
    _$CombinedStopImpl(
      id: json['id'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      amountToCollect: (json['amountToCollect'] as num).toDouble(),
      isVisited: json['isVisited'] as bool,
      visitedAt: const NullableDateTimeConverter().fromJson(
        json['visitedAt'] as String?,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CombinedStopImplToJson(_$CombinedStopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client': instance.client,
      'order': instance.order,
      'amountToCollect': instance.amountToCollect,
      'isVisited': instance.isVisited,
      'visitedAt': const NullableDateTimeConverter().toJson(instance.visitedAt),
      'runtimeType': instance.$type,
    };

_$RouteManifestImpl _$$RouteManifestImplFromJson(Map<String, dynamic> json) =>
    _$RouteManifestImpl(
      driverId: json['driverId'] as String,
      date: const DateTimeConverter().fromJson(json['date'] as String),
      stops: (json['stops'] as List<dynamic>)
          .map((e) => ManifestStop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RouteManifestImplToJson(_$RouteManifestImpl instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'date': const DateTimeConverter().toJson(instance.date),
      'stops': instance.stops,
    };
