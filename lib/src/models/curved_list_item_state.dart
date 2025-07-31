/// Represents the state of an individual item within the [CurvedListWheel].
/// This is passed to the `itemBuilder` to allow for conditional styling.
class CurvedListItemState {
  /// Whether this item is currently selected (in the center).
  final bool isSelected;

  /// The absolute distance from the selected item.
  /// `0` if selected, `1` for immediate neighbors, `2` for the next, and so on.
  final int distance;

  const CurvedListItemState({
    required this.isSelected,
    required this.distance,
  });
}
