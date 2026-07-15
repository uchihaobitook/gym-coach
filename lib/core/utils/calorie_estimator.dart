import '../constants/app_constants.dart';

/// Estimates calories burned during resistance training sessions.
abstract final class CalorieEstimator {
  /// Estimates calories from [duration] using [AppConstants.caloriesPerMinute].
  static double estimate(Duration duration) {
    if (duration.isNegative || duration.inSeconds == 0) return 0;
    final minutes = duration.inSeconds / 60.0;
    return minutes * AppConstants.caloriesPerMinute;
  }

  /// Rounds the estimate to the nearest whole calorie.
  static int estimateRounded(Duration duration) {
    return estimate(duration).round();
  }
}
