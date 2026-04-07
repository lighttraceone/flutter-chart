import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Default top bound quote.
const double defaultTopBoundQuote = 60;

/// Default bottom bound quote.
const double defaultBottomBoundQuote = 30;

/// Default Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
/// Limits panning to the right.
const double defaultMaxCurrentTickOffset = 150;

/// Configuration for the chart axis.
@immutable
class ChartAxisConfig {
  /// Initializes the chart axis configuration.
  const ChartAxisConfig({
    this.initialTopBoundQuote = defaultTopBoundQuote,
    this.initialBottomBoundQuote = defaultBottomBoundQuote,
    this.maxCurrentTickOffset = defaultMaxCurrentTickOffset,
    this.defaultTickOffset,
    this.defaultIntervalWidth = 20,
    this.showQuoteGrid = true,
    this.showEpochGrid = true,
    this.showFrame = false,
    this.smoothScrolling = true,
    this.timeLabelFormatter,
  });

  /// Top quote bound target for animated transition.
  final double initialTopBoundQuote;

  /// Bottom quote bound target for animated transition.
  final double initialBottomBoundQuote;

  /// Max distance between [rightBoundEpoch] and [_nowEpoch] in pixels.
  /// Limits panning to the right.
  final double maxCurrentTickOffset;

  /// Default distance between the latest data point and the right edge of the
  /// chart in pixels.
  ///
  /// This value is used for:
  /// - Initial chart load tick offset
  /// - Target position when "scroll to last tick" button is clicked
  ///
  /// If not specified, defaults to [maxCurrentTickOffset].
  /// The value will be clamped between 0 and [maxCurrentTickOffset].
  final double? defaultTickOffset;

  /// Show Quote Grid lines and labels.
  final bool showQuoteGrid;

  /// Show Epoch Grid lines and labels.
  final bool showEpochGrid;

  /// Show the chart frame and indicators dividers.
  ///
  /// Used in the mobile chart.
  final bool showFrame;

  /// The default distance between two ticks in pixels.
  ///
  /// Default to this interval width on granularity change.
  final double defaultIntervalWidth;

  /// Whether the chart should scroll smoothly.
  /// If `true`, the chart will smoothly adjust the scroll position
  /// (if the last tick is visible) to the right to continuously show new ticks.
  /// If `false`, the chart will only auto-scroll to keep the new tick visible
  /// after receiving a new tick.
  ///
  /// Default is `true`.
  final bool smoothScrolling;

  /// Custom formatter for X-axis time labels.
  ///
  /// When provided, replaces the default [timeLabel] function for rendering
  /// timestamps on the X-axis. Use this to customise the date/time format
  /// per granularity (e.g. `HH:mm` for intraday, `MM/dd` for daily).
  ///
  /// The function receives a [DateTime] in local time and must return the
  /// display string for that timestamp.
  ///
  /// If `null`, the built-in [timeLabel] format logic is used.
  @nonVirtual
  final String Function(DateTime)? timeLabelFormatter;

  /// Creates a copy of this ChartAxisConfig but with the given fields replaced.
  ChartAxisConfig copyWith({
    double? initialTopBoundQuote,
    double? initialBottomBoundQuote,
    double? maxCurrentTickOffset,
    double? defaultTickOffset,
  }) =>
      ChartAxisConfig(
        initialTopBoundQuote: initialTopBoundQuote ?? this.initialTopBoundQuote,
        initialBottomBoundQuote:
            initialBottomBoundQuote ?? this.initialBottomBoundQuote,
        maxCurrentTickOffset: maxCurrentTickOffset ?? this.maxCurrentTickOffset,
        defaultTickOffset: defaultTickOffset ?? this.defaultTickOffset,
      );
}
