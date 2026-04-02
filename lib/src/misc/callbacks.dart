import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/widgets.dart';

/// Called when chart is scrolled or zoomed.
///
/// [leftEpoch] is an epoch value of the chart's left edge.
/// [rightEpoch] is an epoch value of the chart's right edge.
typedef VisibleAreaChangedCallback = Function(int leftEpoch, int rightEpoch);

/// Called when the quotes in y-axis is changed
///
/// [topQuote] is an quote value of the chart's top edge.
/// [bottomQuote] is an quote value of the chart's bottom edge.
typedef VisibleQuoteAreaChangedCallback = Function(
    double topQuote, double bottomQuote);

/// Called when the crosshair is moved
///
/// [globalPosition] of the pointer.
/// [localPosition] of the pointer.
/// [epochToX] is a function to convert epoch value to canvas X.
/// [quoteToY] is a function to convert value(quote) value to canvas Y.
/// [epochFromX] is a function to convert canvas X to epoch value.
/// [quoteFromY] is a function to convert canvas Y to value(quote).
typedef OnCrosshairHover = void Function(
  Offset globalPosition,
  Offset localPosition,
  EpochToX epochToX,
  QuoteToY quoteToY,
  EpochFromX epochFromX,
  QuoteFromY quoteFromY,
);

/// Called when the crosshair is moved
///
/// [globalPosition] of the pointer.
/// [localPosition] of the pointer.
/// [epochToX] is a function to convert epoch value to canvas X.
/// [quoteToY] is a function to convert value(quote) value to canvas Y.
/// [epochFromX] is a function to convert canvas X to epoch value.
/// [quoteFromY] is a function to convert canvas Y to value(quote).
/// [config] is the config of the Indicator if it the hover is in BottomChart.
typedef OnCrosshairHoverCallback = void Function(
  Offset globalPosition,
  Offset localPosition,
  EpochToX epochToX,
  QuoteToY quoteToY,
  EpochFromX epochFromX,
  QuoteFromY quoteFromY,
  AddOnConfig? config,
);

/// Data passed to a custom crosshair details builder.
class CrosshairDetailsData {
  /// Creates crosshair details data.
  const CrosshairDetailsData({
    required this.mainSeries,
    required this.crosshairTick,
    required this.pipSize,
    required this.crosshairVariant,
  });

  /// The chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// The current crosshair tick.
  final Tick crosshairTick;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// The variant of the crosshair to be used.
  final CrosshairVariant crosshairVariant;
}

/// Builds custom crosshair details content.
typedef CrosshairDetailsBuilder = Widget Function(
  BuildContext context,
  CrosshairDetailsData data,
);

/// Builds a custom title widget for a bottom chart indicator.
///
/// [config] is the indicator configuration for this bottom chart.
/// Return `null` to use the default title.
typedef BottomChartTitleBuilder = Widget? Function(
  BuildContext context,
  IndicatorConfig config,
);
