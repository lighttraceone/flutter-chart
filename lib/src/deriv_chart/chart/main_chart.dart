import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_controller.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/misc/chart_controller.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_data_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_area.dart';
import 'package:deriv_chart/src/deriv_chart/chart/loading_animation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../drawing_tool_chart/drawing_tool_chart.dart';
import '../interactive_layer/interactive_layer.dart';
import '../interactive_layer/interactive_layer_behaviours/interactive_layer_behaviour.dart';
import '../interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'basic_chart.dart';
import 'multiple_animated_builder.dart';
import 'data_visualization/annotations/chart_annotation.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/chart_series/data_series.dart';
import 'data_visualization/chart_series/series.dart';
import 'data_visualization/markers/marker_series.dart';
import 'data_visualization/models/animation_info.dart';
import 'data_visualization/models/chart_object.dart';
import 'helpers/functions/helper_functions.dart';
import 'helpers/paint_functions/paint_line.dart';
import '../../misc/callbacks.dart';
import '../../theme/chart_theme.dart';
import '../../theme/painting_styles/visible_price_extremes_style.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';

import 'y_axis/quote_grid.dart';

/// The main chart to display in the chart widget.
class MainChart extends BasicChart {
  /// Initializes the main chart to display in the chart widget.
  MainChart({
    required DataSeries<Tick> mainSeries,
    required this.crosshairVariant,
    required this.showCrosshair,
    this.drawingTools,
    this.isLive = false,
    int pipSize = 4,
    Key? key,
    this.showLoadingAnimationForHistoricalData = true,
    this.showDataFitButton = false,
    this.showScrollToLastTickButton = true,
    this.showVisiblePriceExtremes = false,
    this.visiblePriceExtremesStyle,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.overlaySeries,
    this.annotations,
    this.verticalPaddingFraction,
    this.crosshairDetailsBuilder,
    this.loadingAnimationColor,
    this.showCurrentTickBlinkAnimation = true,
    super.currentTickAnimationDuration,
    super.quoteBoundsAnimationDuration,
    double opacity = 1,
    ChartAxisConfig? chartAxisConfig,
    VisibleQuoteAreaChangedCallback? onQuoteAreaChanged,
    this.interactiveLayerBehaviour,
    this.useDrawingToolsV2 = false,
  })  : _mainSeries = mainSeries,
        chartDataList = <ChartData>[
          mainSeries,
          if (overlaySeries != null) ...overlaySeries,
          if (annotations != null) ...annotations,
        ],
        super(
          key: key,
          mainSeries: mainSeries,
          pipSize: pipSize,
          opacity: opacity,
          chartAxisConfig: chartAxisConfig,
          onQuoteAreaChanged: onQuoteAreaChanged,
        );

  /// Whether to use the new drawing tools v2 or not.
  final bool useDrawingToolsV2;

  /// The indicator series that are displayed on the main chart.
  final List<Series>? overlaySeries;
  final DataSeries<Tick> _mainSeries;

  /// List of chart annotations used in the chart.
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// The series that hold the list markers.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools? drawingTools;

  /// The function that gets called on crosshair appearance.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHover? onCrosshairHover;

  /// Chart's widget controller.
  final ChartController? controller;

  /// Whether the widget is live or not.
  final bool isLive;

  /// Whether the widget is showing loading animation or not.
  final bool showLoadingAnimationForHistoricalData;

  /// Whether to show the data fit button or not.
  final bool showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool showScrollToLastTickButton;

  /// Whether to show highest/lowest visible price markers on the main chart.
  final bool showVisiblePriceExtremes;

  /// Style config for highest/lowest visible price markers on the main chart.
  final VisiblePriceExtremesStyle? visiblePriceExtremesStyle;

  /// Convenience list to access all chart data.
  final List<ChartData> chartDataList;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// Builds custom crosshair details content.
  final CrosshairDetailsBuilder? crosshairDetailsBuilder;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Whether to show current tick blink animation or not.
  final bool showCurrentTickBlinkAnimation;

  /// Defines the interactive layer behaviour. like when adding a tools or
  /// dragging/hovering.
  final InteractiveLayerBehaviour? interactiveLayerBehaviour;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  @override
  _ChartImplementationState createState() => _ChartImplementationState();
}

class _ChartImplementationState extends BasicChartState<MainChart> {
  /// Padding should be at least half of barrier label height.

  late AnimationController _currentTickBlinkingController;

  late Animation<double> _currentTickBlinkAnimation;

  /// The crosshair controller.
  late CrosshairController crosshairController;

  bool get _isScrollToLastTickAvailable =>
      (widget._mainSeries.entries?.isNotEmpty ?? false) &&
      xAxis.rightBoundEpoch < widget._mainSeries.entries!.last.epoch &&
      !crosshairController.isCrosshairActive;

  /// Crosshair related state.
  late AnimationController crosshairZoomOutAnimationController;

  /// The current animation value of crosshair zoom out.
  late Animation<double> crosshairZoomOutAnimation;

  final YAxisNotifier _yAxisNotifier = YAxisNotifier(YAxisModel.zero());

  late final InteractiveLayerBehaviour _interactiveLayerBehaviour;

  @override
  double get verticalPadding {
    if (canvasSize == null) {
      return 0;
    }

    final double padding = verticalPaddingFraction * canvasSize!.height;
    if (BasicChartState.minPadding < canvasSize!.height / 2) {
      return padding.clamp(BasicChartState.minPadding, canvasSize!.height / 2);
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();

    // TODO(Ramin): mention in the document to customize or go with default.
    _interactiveLayerBehaviour =
        widget.interactiveLayerBehaviour ?? InteractiveLayerDesktopBehaviour();

    if (widget.verticalPaddingFraction != null) {
      verticalPaddingFraction = widget.verticalPaddingFraction!;
    }

    _setupController();
    _setupCrosshairController();
  }

  @override
  void didUpdateWidget(MainChart oldChart) {
    super.didUpdateWidget(oldChart);

    didUpdateChartData(oldChart);

    if (widget.isLive != oldChart.isLive ||
        widget.showCurrentTickBlinkAnimation != oldChart.showCurrentTickBlinkAnimation) {
      _updateBlinkingAnimationStatus();
    }

    // Update the crosshair controller when showCrosshair changes
    if (widget.showCrosshair != oldChart.showCrosshair) {
      // Create a new controller with the updated showCrosshair value
      _setupCrosshairController();
    }

    xAxis.update(
      minEpoch: widget.chartDataList.getMinEpoch(),
      maxEpoch: widget.chartDataList.getMaxEpoch(),
    );

    crosshairController
      ..series = widget.mainSeries as DataSeries<Tick>
      ..crosshairVariant = widget.crosshairVariant;
  }

  void _setupCrosshairController() {
    crosshairController = CrosshairController(
      xAxisModel: xAxis,
      series: widget.mainSeries as DataSeries<Tick>,
      onCrosshairAppeared: () {
        if (widget.crosshairVariant == CrosshairVariant.smallScreen) {
          crosshairZoomOutAnimationController.forward();
        }
        widget.onCrosshairAppeared?.call();
      },
      onCrosshairDisappeared: () {
        if (widget.crosshairVariant == CrosshairVariant.smallScreen) {
          crosshairZoomOutAnimationController.reverse();
        }
        widget.onCrosshairDisappeared?.call();
      },
      showCrosshair: widget.showCrosshair,
      quoteFromCanvasY: chartQuoteFromCanvasY,
      crosshairVariant: widget.crosshairVariant,
    );
  }

  void _updateBlinkingAnimationStatus() {
    if (widget.isLive && widget.showCurrentTickBlinkAnimation) {
      _currentTickBlinkingController.repeat(reverse: true);
    } else {
      _currentTickBlinkingController
        ..reset()
        ..stop();
    }
  }

  @override
  void didUpdateChartData(covariant MainChart oldChart) {
    super.didUpdateChartData(oldChart);
    for (final ChartData data in widget.chartDataList.where(
      // Exclude mainSeries, since its didUpdate is already called
      (ChartData d) => d.id != widget.mainSeries.id,
    )) {
      final ChartData? oldData = oldChart.chartDataList.firstWhereOrNull(
        (ChartData d) => d.id == data.id,
      );

      data.didUpdate(oldData);
    }
  }

  @override
  void dispose() {
    _currentTickBlinkingController.dispose();
    crosshairZoomOutAnimationController.dispose();
    super.dispose();
  }

  @override
  void setupAnimations() {
    super.setupAnimations();
    _setupBlinkingAnimation();
    _setupCrosshairZoomOutAnimation();
  }

  void _setupController() {
    widget.controller?.onScrollToLastTick = ({required bool animate}) {
      if (mounted) {
        // TODO(Ramin): add the ability to close the controller.
        xAxis.scrollToLastTick(animate: animate);
      }
    };

    widget.controller?.onCompleteTickAnimation = () {
      if (mounted) {
        completeCurrentTickAnimation();
      }
    };

    widget.controller?.onScale = (double scale) {
      xAxis
        ..onScaleAndPanStart(ScaleStartDetails())
        ..onScaleUpdate(ScaleUpdateDetails(scale: scale));
      return xAxis.msPerPx;
    };

    widget.controller?.onScroll = (double pxShift) {
      xAxis.scrollBy(pxShift);
    };

    widget.controller?.toggleXScrollBlock = ({required bool isXScrollBlocked}) {
      xAxis.isScrollBlocked = isXScrollBlocked;
    };

    widget.controller?.toggleDataFitMode = ({required bool enableDataFit}) {
      if (enableDataFit) {
        xAxis.enableDataFit();
      } else {
        xAxis.disableDataFit();
      }
    };

    widget.controller?.getXFromEpoch = (int epoch) => xAxis.xFromEpoch(epoch);
    widget.controller?.getYFromQuote = (double quote) => chartQuoteToCanvasY(quote);

    widget.controller?.getEpochFromX = (double x) => xAxis.epochFromX(x);
    widget.controller?.getQuoteFromY = (double y) => chartQuoteFromCanvasY(y);

    widget.controller?.getMsPerPx = () => xAxis.msPerPx;
  }

  void _setupCrosshairZoomOutAnimation() {
    crosshairZoomOutAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    crosshairZoomOutAnimation = CurvedAnimation(
      parent: crosshairZoomOutAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _setupBlinkingAnimation() {
    _currentTickBlinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _currentTickBlinkAnimation = CurvedAnimation(
      parent: _currentTickBlinkingController,
      curve: Curves.easeInOut,
    );

    if (widget.showCurrentTickBlinkAnimation) {
      _currentTickBlinkingController.repeat(reverse: true);
    }
  }

  @override
  void updateVisibleData() {
    super.updateVisibleData();

    for (final ChartData data in widget.chartDataList) {
      data.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final XAxisModel xAxis = context.watch<XAxisModel>();

          canvasSize = Size(
            xAxis.width!,
            constraints.maxHeight,
          );

          if (yAxisModel != null) {
            _yAxisNotifier.value = yAxisModel!;
          }

          updateVisibleData();
          return ListenableProvider<YAxisNotifier>.value(
            value: _yAxisNotifier,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (widget.showLoadingAnimationForHistoricalData ||
                    (widget._mainSeries.entries?.isEmpty ?? false))
                  _buildLoadingAnimation(),
                super.build(context),
                if (widget.overlaySeries != null) _buildSeries(widget.overlaySeries!),
                if (widget.markerSeries != null) _buildMarkerArea(),
                if (widget.showVisiblePriceExtremes) _buildVisiblePriceExtremes(context, xAxis),
                _buildAnnotations(),
                if (widget.drawingTools != null && !widget.useDrawingToolsV2)
                  _buildDrawingToolChart(widget.drawingTools!),
                if (widget.drawingTools != null &&
                    (widget.useDrawingToolsV2 || widget.showCrosshair))
                  _buildInteractiveLayer(context, xAxis),
                if (widget.showScrollToLastTickButton && _isScrollToLastTickAvailable)
                  Positioned(
                    bottom: 0,
                    right: quoteLabelsTouchAreaWidth,
                    child: _buildScrollToLastTickButton(),
                  ),
                if (widget.showDataFitButton && (widget._mainSeries.entries?.isNotEmpty ?? false))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildDataFitButton(),
                  ),
              ],
            ),
          );
        },
      );

  Widget _buildVisiblePriceExtremes(
    BuildContext context,
    XAxisModel xAxis,
  ) {
    final List<Tick> visibleEntries =
        (widget.mainSeries as DataSeries<Tick>).visibleEntries.entries;
    if (visibleEntries.isEmpty || visibleEntries.first is! Candle) {
      return const SizedBox.shrink();
    }

    Candle? highest;
    Candle? lowest;

    for (final Tick tick in visibleEntries) {
      if (tick is! Candle) {
        continue;
      }

      if (highest == null || tick.high > highest.high) {
        highest = tick;
      }
      if (lowest == null || tick.low < lowest.low) {
        lowest = tick;
      }
    }

    if (highest == null && lowest == null) {
      return const SizedBox.shrink();
    }

    return MultipleAnimatedBuilder(
      animations: <Listenable>[
        topBoundQuoteAnimationController,
        bottomBoundQuoteAnimationController,
        _yAxisNotifier,
      ],
      builder: (BuildContext context, _) {
        final double plotWidth = xAxis.graphAreaWidth ?? xAxis.width ?? 0;
        if (plotWidth <= 0) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double constrainedPlotWidth = min(plotWidth, constraints.maxWidth);

            return IgnorePointer(
              child: Stack(
                children: <Widget>[
                  if (highest != null)
                    _buildVisiblePriceMarker(
                      context,
                      candle: highest,
                      price: highest.high,
                      isHigh: true,
                      plotWidth: constrainedPlotWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                  if (lowest != null)
                    _buildVisiblePriceMarker(
                      context,
                      candle: lowest,
                      price: lowest.low,
                      isHigh: false,
                      plotWidth: constrainedPlotWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVisiblePriceMarker(
    BuildContext context, {
    required Candle candle,
    required double price,
    required bool isHigh,
    required double plotWidth,
    required double maxHeight,
  }) {
    final _ResolvedVisiblePriceExtremesStyle style = _resolveVisiblePriceExtremesStyle(context);
    final double x = xAxis.xFromEpoch(candle.epoch);
    final double y = chartQuoteToCanvasY(price);
    const double minTop = 2;
    final String valueText = price.toStringAsFixed(widget.pipSize);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: valueText, style: style.textStyle),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final double labelWidth = textPainter.width + style.padding.horizontal;
    final double markerHeight = max(textPainter.height + style.padding.vertical, 20);
    final double totalWidth = style.guideLineLength + style.labelSpacing + labelWidth;
    final bool canPlaceRight = x + totalWidth <= plotWidth;
    final bool canPlaceLeft = x - totalWidth >= 0;
    final bool placeRight = canPlaceRight || (!canPlaceLeft && x <= plotWidth / 2);
    final double left = placeRight
        ? x.clamp(0.0, max(plotWidth - totalWidth, 0.0)).toDouble()
        : max(0, x - totalWidth).toDouble();
    final double top = (isHigh ? y - style.highPriceTopOffset : y - style.lowPriceTopOffset)
        .clamp(minTop, max(maxHeight - markerHeight, minTop))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: placeRight
            ? <Widget>[
                _VisiblePriceExtremesGuideLine(style: style),
                SizedBox(width: style.labelSpacing),
                _buildVisiblePriceLabel(valueText, style),
              ]
            : <Widget>[
                _buildVisiblePriceLabel(valueText, style),
                SizedBox(width: style.labelSpacing),
                _VisiblePriceExtremesGuideLine(style: style),
              ],
      ),
    );
  }

  Widget _buildVisiblePriceLabel(
    String value,
    _ResolvedVisiblePriceExtremesStyle style,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: style.borderRadius,
      ),
      child: Padding(
        padding: style.padding,
        child: Text(
          value,
          style: style.textStyle,
        ),
      ),
    );
  }

  _ResolvedVisiblePriceExtremesStyle _resolveVisiblePriceExtremesStyle(
    BuildContext context,
  ) {
    final ChartTheme theme = context.watch<ChartTheme>();
    final VisiblePriceExtremesStyle style =
        widget.visiblePriceExtremesStyle ?? const VisiblePriceExtremesStyle();

    return _ResolvedVisiblePriceExtremesStyle(
      textStyle: style.textStyle ??
          theme.gridTextStyle.copyWith(
            color: theme.gridTextColor,
          ),
      backgroundColor: style.backgroundColor ?? theme.backgroundColor.withValues(alpha: 0.92),
      guideLineColor: style.guideLineColor ?? theme.gridTextColor,
      padding: style.padding,
      borderRadius: style.borderRadius,
      guideLineLength: style.guideLineLength,
      guideLineThickness: style.guideLineThickness,
      dashWidth: style.dashWidth,
      dashSpace: style.dashSpace,
      labelSpacing: style.labelSpacing,
      highPriceTopOffset: style.highPriceTopOffset,
      lowPriceTopOffset: style.lowPriceTopOffset,
    );
  }

  // ignore: unused_element
  Widget _buildInteractiveLayer(BuildContext context, XAxisModel xAxis) => MultipleAnimatedBuilder(
        animations: [
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
          _yAxisNotifier,
        ],
        builder: (_, __) {
          return InteractiveLayer(
            drawingTools: widget.drawingTools!,
            series: widget.mainSeries as DataSeries<Tick>,
            drawingToolsRepo: context.watch<Repository<DrawingToolConfig>>(),
            chartConfig: context.watch<ChartConfig>(),
            quoteToCanvasY: chartQuoteToCanvasY,
            epochToCanvasX: xAxis.xFromEpoch,
            quoteFromCanvasY: chartQuoteFromCanvasY,
            epochFromCanvasX: xAxis.epochFromX,
            quoteRange: QuoteRange(
              topQuote: chartQuoteFromCanvasY(0),
              bottomQuote: chartQuoteFromCanvasY(_yAxisNotifier.value.canvasHeight),
            ),
            interactiveLayerBehaviour: _interactiveLayerBehaviour,
            crosshairController: crosshairController,
            crosshairVariant: widget.crosshairVariant,
            crosshairZoomOutAnimation: crosshairZoomOutAnimation,
            pipSize: widget.pipSize,
            crosshairDetailsBuilder: widget.crosshairDetailsBuilder,
          );
        },
      );

  // ignore: unused_element
  Widget _buildDrawingToolChart(DrawingTools drawingTools) => MultipleAnimatedBuilder(
        animations: <Listenable>[
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
        ],
        builder: (_, Widget? child) => DrawingToolChart(
          series: widget.mainSeries as DataSeries<Tick>,
          chartQuoteToCanvasY: chartQuoteToCanvasY,
          chartQuoteFromCanvasY: chartQuoteFromCanvasY,
          drawingTools: drawingTools,
        ),
      );

  Widget _buildLoadingAnimation() => LoadingAnimationArea(
        loadingRightBoundX: widget._mainSeries.input.isEmpty
            ? xAxis.width!
            : xAxis.xFromEpoch(widget._mainSeries.input.first.epoch),
        loadingAnimationColor: widget.loadingAnimationColor,
      );

  Widget _buildAnnotations() => MultipleAnimatedBuilder(
        animations: <Animation<double>>[
          currentTickAnimation,
          _currentTickBlinkAnimation,
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
        ],
        builder: (BuildContext context, _) => Stack(fit: StackFit.expand, children: <Widget>[
          if (widget.annotations != null)
            ...widget.annotations!
                .map(
                  (ChartData annotation) => RepaintBoundary(
                    child: CustomPaint(
                      key: ValueKey<String>(annotation.id),
                      painter: ChartPainter(
                        animationInfo: AnimationInfo(
                          currentTickPercent: currentTickAnimation.value,
                          blinkingPercent: _currentTickBlinkAnimation.value,
                        ),
                        chartData: annotation,
                        chartConfig: context.watch<ChartConfig>(),
                        theme: context.watch<ChartTheme>(),
                        epochToCanvasX: xAxis.xFromEpoch,
                        quoteToCanvasY: chartQuoteToCanvasY,
                        chartScaleModel: context.watch<ChartScaleModel>(),
                      ),
                    ),
                  ),
                )
                .toList()
        ]),
      );

  Widget _buildScrollToLastTickButton() => Material(
        type: MaterialType.circle,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: xAxis.scrollToLastTick,
          color: context.read<ChartTheme>().base01Color,
        ),
      );

  // Main series and indicators on top of main series.
  Widget _buildSeries(List<Series> series) => MultipleAnimatedBuilder(
        animations: <Listenable>[
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController,
          crosshairZoomOutAnimation,
        ],
        builder: (BuildContext context, Widget? child) => RepaintBoundary(
          child: CustomPaint(
            painter: BaseChartDataPainter(
              animationInfo: AnimationInfo(
                currentTickPercent: currentTickAnimation.value,
              ),
              series: series,
              chartConfig: context.watch<ChartConfig>(),
              theme: context.watch<ChartTheme>(),
              epochToCanvasX: xAxis.xFromEpoch,
              quoteToCanvasY: chartQuoteToCanvasY,
              rightBoundEpoch: xAxis.rightBoundEpoch,
              leftBoundEpoch: xAxis.leftBoundEpoch,
              topY: chartQuoteToCanvasY(widget.mainSeries.maxValue),
              bottomY: chartQuoteToCanvasY(widget.mainSeries.minValue),
              chartScaleModel: context.watch<ChartScaleModel>(),
            ),
          ),
        ),
      );

  Widget _buildMarkerArea() => MultipleAnimatedBuilder(
        animations: <Listenable>[
          currentTickAnimation,
          topBoundQuoteAnimationController,
          bottomBoundQuoteAnimationController
        ],
        builder: (BuildContext context, _) => MarkerArea(
          markerSeries: widget.markerSeries!,
          quoteToCanvasY: chartQuoteToCanvasY,
          animationInfo: AnimationInfo(
            currentTickPercent: currentTickAnimation.value,
          ),
        ),
      );

  Widget _buildDataFitButton() {
    final XAxisModel xAxis = context.read<XAxisModel>();
    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: const Icon(Icons.fullscreen_exit),
        onPressed: xAxis.dataFitEnabled ? null : xAxis.enableDataFit,
      ),
    );
  }

  @override
  List<double> getSeriesMinMaxValue() {
    final List<double> minMaxValues = super.getSeriesMinMaxValue();
    double minQuote = minMaxValues[0];
    double maxQuote = minMaxValues[1];

    minQuote = safeMin(minQuote, widget.chartDataList.getMinValue());
    maxQuote = safeMax(maxQuote, widget.chartDataList.getMaxValue());
    return <double>[minQuote, maxQuote];
  }
}

class _ResolvedVisiblePriceExtremesStyle {
  const _ResolvedVisiblePriceExtremesStyle({
    required this.textStyle,
    required this.backgroundColor,
    required this.guideLineColor,
    required this.padding,
    required this.borderRadius,
    required this.guideLineLength,
    required this.guideLineThickness,
    required this.dashWidth,
    required this.dashSpace,
    required this.labelSpacing,
    required this.highPriceTopOffset,
    required this.lowPriceTopOffset,
  });

  final TextStyle textStyle;
  final Color backgroundColor;
  final Color guideLineColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double guideLineLength;
  final double guideLineThickness;
  final double dashWidth;
  final double dashSpace;
  final double labelSpacing;
  final double highPriceTopOffset;
  final double lowPriceTopOffset;
}

class _VisiblePriceExtremesGuideLine extends StatelessWidget {
  const _VisiblePriceExtremesGuideLine({
    required this.style,
  });

  final _ResolvedVisiblePriceExtremesStyle style;

  @override
  Widget build(BuildContext context) {
    final double height = max(
      style.textStyle.fontSize ?? 12,
      style.guideLineThickness,
    );

    return CustomPaint(
      size: Size(style.guideLineLength, height),
      painter: _VisiblePriceExtremesGuideLinePainter(style),
    );
  }
}

class _VisiblePriceExtremesGuideLinePainter extends CustomPainter {
  const _VisiblePriceExtremesGuideLinePainter(this.style);

  final _ResolvedVisiblePriceExtremesStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    paintHorizontalDashedLine(
      canvas,
      0,
      size.width,
      size.height / 2,
      style.guideLineColor,
      style.guideLineThickness,
      dashWidth: style.dashWidth,
      dashSpace: style.dashSpace,
    );
  }

  @override
  bool shouldRepaint(covariant _VisiblePriceExtremesGuideLinePainter oldDelegate) {
    return oldDelegate.style != style;
  }
}
