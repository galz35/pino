import 'package:json_annotation/json_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String date) {
    return DateTime.parse(date);
  }

  @override
  String toJson(DateTime date) {
    return date.toIso8601String();
  }
}

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? date) {
    return date == null ? null : DateTime.parse(date);
  }

  @override
  String? toJson(DateTime? date) {
    return date?.toIso8601String();
  }
}
