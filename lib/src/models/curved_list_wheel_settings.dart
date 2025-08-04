import 'package:flutter/material.dart';

import 'haptic_feedback_intensity.dart';

/// Settings to configure the appearance and behavior of the CurvedListWheel.
class CurvedListWheelSettings {
  /// The fixed extent of each item in the wheel, measured along the scroll axis.
  /// For vertical lists (`.left`/`.right`), this is the item's height.
  /// For horizontal lists (`.top`/`.bottom`), this is the item's width.
  final double itemExtent;

  /// A factor to control the tightness of the curve. A larger value creates a
  /// more pronounced curve. Defaults to 0.7.
  final double pathCurveFactor;

  /// Whether to show the highlight box in the center.
  final bool showHighlight;

  /// The color of the central highlight box.
  final Color highlightColor;

  /// The width of the highlight box, as a fraction of the available width.
  /// **This is primarily used for `.left` and `.right` sides.**
  /// If `highlightHeightFactor` is not provided, this value is also used as a
  /// fallback for the height on `.top` and `.bottom` sides.
  /// Defaults to `0.7`.
  final double highlightWidthFactor;

  /// The height of the highlight box, as a fraction of the available height.
  /// **This is used for `.top` and `.bottom` sides.**
  /// If this is null, `highlightWidthFactor` is used as a fallback.
  final double? highlightHeightFactor;

  /// The border radius of the highlight box.
  final BorderRadius? highlightBorderRadius;

  /// Whether to trigger haptic feedback when an item is selected.
  /// Defaults to `true`.
  final bool enableHapticFeedback;

  /// The intensity of the haptic feedback.
  /// Defaults to [HapticFeedbackIntensity.medium].
  final HapticFeedbackIntensity hapticFeedbackIntensity;

  /// Creates a configuration object for the [CurvedListWheel].
  const CurvedListWheelSettings({
    this.itemExtent = 65.0,
    this.pathCurveFactor = 0.7,
    this.showHighlight = true,
    this.highlightColor = const Color(0x26FF6B00),
    this.highlightWidthFactor = 0.7,
    this.highlightHeightFactor,
    this.highlightBorderRadius,
    this.enableHapticFeedback = true,
    this.hapticFeedbackIntensity = HapticFeedbackIntensity.medium,
  });
}
