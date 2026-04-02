import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_line_painter.dart';
import 'package:flutter/material.dart';

/// A custom painter to paint the crosshair `line`.
class SmallScreenCrosshairLinePainter extends CrosshairLinePainter {
  /// Initializes a custom painter to paint the crosshair `line` for small screens.
  const SmallScreenCrosshairLinePainter({
    required super.theme,
    super.cursorX,
    super.cursorY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Color lineColor = theme.crosshairLineDesktopColor;

    paintVerticalDashedLine(
      canvas,
      cursorX,
      8,
      size.height,
      lineColor,
      1,
    );

    paintHorizontalDashedLine(
      canvas,
      0,
      size.width,
      cursorY,
      lineColor,
      1,
    );
  }
}
