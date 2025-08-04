import 'package:flutter/services.dart';

/// Defines the intensity of the haptic feedback when an item is selected.
enum HapticFeedbackIntensity {
  /// No haptic feedback.
  none,

  /// A light haptic feedback, corresponding to [HapticFeedback.lightImpact].
  light,

  /// A medium haptic feedback, corresponding to [HapticFeedback.mediumImpact].
  medium,

  /// A heavy haptic feedback, corresponding to [HapticFeedback.heavyImpact].
  heavy,

  /// A standard selection feedback, corresponding to [HapticFeedback.selectionClick].
  selection,

  /// A vibration feedback, corresponding to [HapticFeedback.vibrate].
  vibrate,
}
