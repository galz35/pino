import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'visit_log.freezed.dart';
part 'visit_log.g.dart';

@freezed
class VisitLog with _$VisitLog {
  const factory VisitLog({
    required String id,
    required String clientId,
    required String clientName,
    required String storeId,
    required String vendorId,
    @DateTimeConverter() required DateTime date,
    required String status, // 'visited_with_order' or 'visited_no_order'
    String? orderId,
    String? notes,
  }) = _VisitLog;

  factory VisitLog.fromJson(Map<String, dynamic> json) =>
      _$VisitLogFromJson(json);
}
