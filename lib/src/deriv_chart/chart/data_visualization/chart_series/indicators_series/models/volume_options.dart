import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';

import 'indicator_options.dart';

/// Volume indicator options.
class VolumeOptions extends IndicatorOptions {
  /// Initializes Volume options.
  const VolumeOptions({
    this.barStyle = const BarStyle(),
    bool showLastIndicator = false,
    int pipSize = 0,
  }) : super(
          showLastIndicator: showLastIndicator,
          pipSize: pipSize,
        );

  /// Volume bar style.
  final BarStyle barStyle;

  @override
  List<Object> get props => <Object>[barStyle];
}
