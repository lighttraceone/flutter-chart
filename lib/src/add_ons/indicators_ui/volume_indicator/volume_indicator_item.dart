import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'volume_indicator_config.dart';

/// Volume indicator item in the list of indicators which provides this
/// indicator's options menu.
class VolumeIndicatorItem extends IndicatorItem {
  /// Initializes
  const VolumeIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    VolumeIndicatorConfig config = const VolumeIndicatorConfig(),
  }) : super(
          key: key,
          title: 'Volume',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      VolumeIndicatorItemState();
}

/// Volume indicator item state.
class VolumeIndicatorItemState
    extends IndicatorItemState<VolumeIndicatorConfig> {
  @override
  VolumeIndicatorConfig updateIndicatorConfig() =>
      (widget.config as VolumeIndicatorConfig).copyWith();

  @override
  Widget getIndicatorOptions() => const SizedBox.shrink();
}
