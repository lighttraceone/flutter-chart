import 'package:flutter/material.dart';

/// Style for highest/lowest visible price markers on the main chart.
class VisiblePriceExtremesStyle {
  /// Creates style config for visible price markers.
  const VisiblePriceExtremesStyle({
    this.textStyle,
    this.backgroundColor,
    this.guideLineColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.guideLineLength = 20,
    this.guideLineThickness = 1,
    this.dashWidth = 2,
    this.dashSpace = 2,
    this.labelSpacing = 4,
    this.highPriceTopOffset = 10,
    this.lowPriceTopOffset = 7,
  });

  /// Text style of the visible price label.
  final TextStyle? textStyle;

  /// Background color of the label.
  final Color? backgroundColor;

  /// Dashed guide line color.
  final Color? guideLineColor;

  /// Inner padding of the label.
  final EdgeInsets padding;

  /// Border radius of the label background.
  final BorderRadius borderRadius;

  /// Length of the dashed guide line.
  final double guideLineLength;

  /// Stroke width of the dashed guide line.
  final double guideLineThickness;

  /// Dash width of the guide line.
  final double dashWidth;

  /// Dash gap of the guide line.
  final double dashSpace;

  /// Gap between the guide line and label.
  final double labelSpacing;

  /// Offset of the highest visible price marker.
  final double highPriceTopOffset;

  /// Offset of the lowest visible price marker.
  final double lowPriceTopOffset;

  /// Creates a copy of this object.
  VisiblePriceExtremesStyle copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? guideLineColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? guideLineLength,
    double? guideLineThickness,
    double? dashWidth,
    double? dashSpace,
    double? labelSpacing,
    double? highPriceTopOffset,
    double? lowPriceTopOffset,
  }) =>
      VisiblePriceExtremesStyle(
        textStyle: textStyle ?? this.textStyle,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        guideLineColor: guideLineColor ?? this.guideLineColor,
        padding: padding ?? this.padding,
        borderRadius: borderRadius ?? this.borderRadius,
        guideLineLength: guideLineLength ?? this.guideLineLength,
        guideLineThickness: guideLineThickness ?? this.guideLineThickness,
        dashWidth: dashWidth ?? this.dashWidth,
        dashSpace: dashSpace ?? this.dashSpace,
        labelSpacing: labelSpacing ?? this.labelSpacing,
        highPriceTopOffset: highPriceTopOffset ?? this.highPriceTopOffset,
        lowPriceTopOffset: lowPriceTopOffset ?? this.lowPriceTopOffset,
      );
}
