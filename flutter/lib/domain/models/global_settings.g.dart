// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalSettingsImpl _$$GlobalSettingsImplFromJson(Map<String, dynamic> json) =>
    _$GlobalSettingsImpl(
      defaultCreditDays: (json['defaultCreditDays'] as num).toInt(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$GlobalSettingsImplToJson(
  _$GlobalSettingsImpl instance,
) => <String, dynamic>{
  'defaultCreditDays': instance.defaultCreditDays,
  'exchangeRate': instance.exchangeRate,
};
