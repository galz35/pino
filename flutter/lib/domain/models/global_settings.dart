import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_settings.freezed.dart';
part 'global_settings.g.dart';

@freezed
abstract class GlobalSettings with _$GlobalSettings {
  const factory GlobalSettings({
    required int defaultCreditDays,
    required double exchangeRate,
  }) = _GlobalSettings;

  factory GlobalSettings.fromJson(Map<String, dynamic> json) =>
      _$GlobalSettingsFromJson(json);
}
