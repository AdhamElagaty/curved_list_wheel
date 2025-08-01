import 'package:flutter/material.dart';

/// Defines the text styling for items in the [CurvedListWheel],
/// especially when using the [CurvedListWheelTextItem] helper.
class CurvedListWheelTextStyle {
  /// The style for the currently selected item in the center.
  final TextStyle selectedStyle;

  /// The default style for items that are not selected and do not have
  /// a distance-specific style.
  final TextStyle unselectedStyle;

  /// A map of styles for items based on their distance from the selected item.
  /// The key is the distance (e.g., 1 for immediate neighbors, 2 for the next),
  /// and the value is the [TextStyle] to apply.
  final Map<int, TextStyle> distanceSpecificStyles;

  const CurvedListWheelTextStyle({
    this.selectedStyle = const TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      color: Colors.deepOrange,
    ),
    this.unselectedStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
    this.distanceSpecificStyles = const {
      1: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
      2: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: Colors.black38,
      ),
    },
  });
}
