// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolumeIndicatorConfig _$VolumeIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    VolumeIndicatorConfig(
      barStyle: json['barStyle'] == null
          ? const BarStyle()
          : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 0,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$VolumeIndicatorConfigToJson(
        VolumeIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'barStyle': instance.barStyle,
    };
