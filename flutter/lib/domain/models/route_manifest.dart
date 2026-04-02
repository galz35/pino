import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';
import 'client.dart';
import 'order.dart';

part 'route_manifest.freezed.dart';
part 'route_manifest.g.dart';

@freezed
sealed class ManifestStop with _$ManifestStop {
  const factory ManifestStop.delivery({
    required String id,
    required Client client,
    required Order order,
    required bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  }) = DeliveryStop;

  const factory ManifestStop.collection({
    required String id,
    required Client client,
    required double amountToCollect,
    required bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  }) = CollectionStop;

  const factory ManifestStop.combined({
    required String id,
    required Client client,
    required Order order,
    required double amountToCollect,
    required bool isVisited,
    @NullableDateTimeConverter() DateTime? visitedAt,
  }) = CombinedStop;

  factory ManifestStop.fromJson(Map<String, dynamic> json) =>
      _$ManifestStopFromJson(json);
}

@freezed
class RouteManifest with _$RouteManifest {
  const factory RouteManifest({
    required String driverId,
    @DateTimeConverter() required DateTime date,
    required List<ManifestStop> stops,
  }) = _RouteManifest;

  factory RouteManifest.fromJson(Map<String, dynamic> json) =>
      _$RouteManifestFromJson(json);
}
