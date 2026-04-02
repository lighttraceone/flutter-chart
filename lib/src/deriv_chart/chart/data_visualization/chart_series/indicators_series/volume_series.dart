import 'package:deriv_chart/src/add_ons/indicators_ui/volume_indicator/volume_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/volume_bar_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_dot_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_highlight_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';
import 'models/volume_options.dart';

/// Volume series that displays trading volume as bar chart.
///
/// Unlike other indicators that compute values via technical analysis,
/// Volume reads the volume field directly from [Candle] data.
class VolumeSeries extends Series {
  /// Initializes
  VolumeSeries(
    this.candles, {
    required this.options,
    required this.config,
    String? id,
  }) : super(id ?? 'Volume$options');

  /// The original candle data.
  final List<Tick> candles;

  /// Volume configuration.
  VolumeIndicatorConfig config;

  /// Volume options.
  VolumeOptions options;

  /// Internal data series for volume bar data.
  late _VolumeDataSeries _volumeDataSeries;

  @override
  SeriesPainter<Series>? createPainter() {
    final List<Tick> volumeTicks = _extractVolumeTicks();

    _volumeDataSeries = _VolumeDataSeries(
      volumeTicks,
      candles: candles,
      style: options.barStyle,
    );

    return null;
  }

  List<Tick> _extractVolumeTicks() => candles.map((Tick tick) {
        final double volume = tick is Candle ? (tick.volume ?? 0) : 0;
        return Tick(epoch: tick.epoch, quote: volume);
      }).toList();

  @override
  bool didUpdate(ChartData? oldData) {
    final VolumeSeries? oldSeries = oldData as VolumeSeries?;

    final List<Tick> volumeTicks = _extractVolumeTicks();

    final _VolumeDataSeries newDataSeries = _VolumeDataSeries(
      volumeTicks,
      candles: candles,
      style: options.barStyle,
    );

    final bool updated =
        newDataSeries.didUpdate(oldSeries?._volumeDataSeries);
    _volumeDataSeries = newDataSeries;

    return updated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _volumeDataSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final double max = _volumeDataSeries.maxValue;
    return <double>[0, max.isNaN ? 0 : max];
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartScaleModel chartScaleModel,
  ) {
    _volumeDataSeries.paint(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      theme,
      chartScaleModel,
    );
  }

  @override
  int? getMaxEpoch() => _volumeDataSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => _volumeDataSeries.getMinEpoch();
}

/// Internal DataSeries for volume tick data.
class _VolumeDataSeries extends DataSeries<Tick> {
  _VolumeDataSeries(
    List<Tick> entries, {
    required this.candles,
    BarStyle? style,
  }) : super(
          entries,
          id: 'VolumeDataSeries',
          style: style,
        );

  /// The original candle data used to determine bar color.
  final List<Tick> candles;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => VolumeBarPainter(
        this,
        candles: candles,
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize, ChartTheme theme,
          CrosshairVariant crosshairVariant) =>
      Text(
        crossHairTick.quote.toStringAsFixed(0),
        style: theme.crosshairInformationBoxQuoteStyle.copyWith(
          color: theme.crosshairInformationBoxTextDefault,
        ),
      );

  @override
  CrosshairHighlightPainter getCrosshairHighlightPainter(
      Tick crosshairTick,
      double Function(double) quoteToY,
      double xCenter,
      int granularity,
      double Function(int) xFromEpoch,
      ChartTheme theme) {
    return CrosshairLineHighlightPainter(
      tick: crosshairTick,
      quoteToY: quoteToY,
      xCenter: xCenter,
      pointColor: Colors.transparent,
      pointSize: 0,
    );
  }

  @override
  CrosshairDotPainter getCrosshairDotPainter(ChartTheme theme) {
    return const CrosshairDotPainter(
      dotColor: Colors.transparent,
      dotBorderColor: Colors.transparent,
    );
  }

  @override
  double getCrosshairDetailsBoxHeight() => 50;

  @override
  Tick createVirtualTick(int epoch, double quote) =>
      Tick(epoch: epoch, quote: quote);
}
