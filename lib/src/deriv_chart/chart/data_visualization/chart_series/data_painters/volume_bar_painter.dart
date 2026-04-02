import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painting.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_painter.dart';
import '../data_series.dart';
import '../indexed_entry.dart';

/// A [DataPainter] for painting volume bars.
///
/// Unlike [BarPainter] which draws from a zero line, volume bars always draw
/// from the bottom of the chart area upward.
class VolumeBarPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  VolumeBarPainter(
    DataSeries<Tick> series, {
    required this.candles,
  }) : super(series);

  /// The original candle data used to determine bar color (up/down).
  final List<Tick> candles;

  late Paint _positiveBarPaint;
  late Paint _negativeBarPaint;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    if (series.visibleEntries.length < 2) {
      return;
    }

    final double intervalWidth =
        epochToX(chartConfig.granularity) - epochToX(0);
    final double barWidth = intervalWidth * 0.8;
    final double bottomY = size.height;

    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries![i];
      final bool isUp = _isCandleUp(i);

      _paintVolumeBar(
        canvas,
        BarPainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(tick, i)),
          yQuote: quoteToY(tick.quote),
          painter: _painterColor(isPositive: isUp),
        ),
        bottomY,
      );
    }

    // Paint last visible tick with animation support.
    final Tick lastTick = series.entries!.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    final bool isLastUp = _isCandleUp(series.entries!.length - 1);

    BarPainting lastTickPainting;

    if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
      final IndexedEntry<Tick> prevLastTick = series.prevLastEntry!;

      final double animatedYQuote = quoteToY(ui.lerpDouble(
        prevLastTick.entry.quote,
        lastTick.quote,
        animationInfo.currentTickPercent,
      )!);

      final double xCenter = ui.lerpDouble(
        epochToX(getEpochOf(prevLastTick.entry, prevLastTick.index)),
        epochToX(getEpochOf(lastTick, series.entries!.length - 1)),
        animationInfo.currentTickPercent,
      )!;

      lastTickPainting = BarPainting(
        xCenter: xCenter,
        yQuote: animatedYQuote,
        width: barWidth,
        painter: _painterColor(isPositive: isLastUp),
      );
    } else {
      lastTickPainting = BarPainting(
        xCenter: epochToX(
            getEpochOf(lastVisibleTick, series.visibleEntries.endIndex - 1)),
        yQuote: quoteToY(lastVisibleTick.quote),
        width: barWidth,
        painter: _painterColor(isPositive: isLastUp),
      );
    }

    _paintVolumeBar(canvas, lastTickPainting, bottomY);
  }

  /// Determines if the candle at [index] is bullish (close >= open).
  bool _isCandleUp(int index) {
    if (index < 0 || index >= candles.length) {
      return true;
    }
    final Tick tick = candles[index];
    if (tick is Candle) {
      return tick.close >= tick.open;
    }
    // For non-candle ticks, compare with previous.
    if (index > 0) {
      return tick.quote >= candles[index - 1].quote;
    }
    return true;
  }

  void _paintVolumeBar(Canvas canvas, BarPainting barPainting, double bottomY) {
    canvas.drawRect(
      Rect.fromLTRB(
        barPainting.xCenter - barPainting.width / 2,
        barPainting.yQuote,
        barPainting.xCenter + barPainting.width / 2,
        bottomY,
      ),
      barPainting.painter,
    );
  }

  Paint _painterColor({required bool isPositive}) {
    final BarStyle style = series.style as BarStyle? ?? theme.barStyle;

    _positiveBarPaint = Paint()..color = style.positiveColor;
    _negativeBarPaint = Paint()..color = style.negativeColor;
    return isPositive ? _positiveBarPaint : _negativeBarPaint;
  }
}
