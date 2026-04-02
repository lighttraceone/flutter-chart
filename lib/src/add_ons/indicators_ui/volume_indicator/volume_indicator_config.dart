import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/volume_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/volume_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'volume_indicator_item.dart';

part 'volume_indicator_config.g.dart';

/// Volume Indicator Config
@JsonSerializable()
class VolumeIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const VolumeIndicatorConfig({
    this.barStyle = const BarStyle(),
    int pipSize = 0,
    bool showLastIndicator = false,
    String? title,
    super.number,
  }) : super(
          isOverlay: false,
          pipSize: pipSize,
          showLastIndicator: showLastIndicator,
          title: title ?? VolumeIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory VolumeIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$VolumeIndicatorConfigFromJson(json);

  @override
  Series getSeries(IndicatorInput indicatorInput) => VolumeSeries(
        indicatorInput.entries,
        config: this,
        options: VolumeOptions(
          barStyle: barStyle,
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        ),
      );

  /// Unique name for this indicator.
  static const String name = 'volume';

  @override
  Map<String, dynamic> toJson() => _$VolumeIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Volume bar style.
  final BarStyle barStyle;

  @override
  String get configSummary => '';

  @override
  String get shortTitle => 'Vol';

  @override
  String get title => 'Volume';

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      VolumeIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  VolumeIndicatorConfig copyWith({
    BarStyle? barStyle,
    int? pipSize,
    bool? showLastIndicator,
    String? title,
    int? number,
  }) =>
      VolumeIndicatorConfig(
        barStyle: barStyle ?? this.barStyle,
        pipSize: pipSize ?? this.pipSize,
        showLastIndicator: showLastIndicator ?? this.showLastIndicator,
        title: title ?? this.title,
        number: number ?? this.number,
      );
}
