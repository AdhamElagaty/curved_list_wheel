import 'package:flutter/material.dart';

import '../models/curved_list_item_state.dart';
import '../models/curved_list_wheel_text_style.dart';

/// A helper widget for easily displaying styled text within a [CurvedListWheel].
///
/// It uses a [CurvedListWheelTextStyle] object to automatically apply different
/// styles based on whether the item is selected, or its distance from center.
class CurvedListWheelTextItem extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The state of the item, provided by the [CurvedListWheel.itemBuilder].
  final CurvedListItemState itemState;

  /// The styling configuration for the text.
  final CurvedListWheelTextStyle style;

  /// Creates a helper widget for displaying styled text in a [CurvedListWheel].
  const CurvedListWheelTextItem({
    super.key,
    required this.text,
    required this.itemState,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle effectiveStyle = style.unselectedStyle;

    if (itemState.isSelected) {
      effectiveStyle = style.selectedStyle;
    } else if (style.distanceSpecificStyles.containsKey(itemState.distance)) {
      effectiveStyle = style.distanceSpecificStyles[itemState.distance]!;
    }

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: effectiveStyle,
      child: Text(text),
    );
  }
}
