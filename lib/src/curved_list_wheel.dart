import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/curved_list_item_state.dart';
import 'models/curved_list_wheel_settings.dart';
import 'models/curved_list_wheel_side.dart';
import 'models/haptic_feedback_intensity.dart';

/// A highly customizable list wheel widget that scrolls items along a curved path.
///
/// The [CurvedListWheel] supports both vertical and horizontal scrolling,
/// with the curve appearing on the left, right, top, or bottom. It is generic,
/// allowing it to display a list of any data type [T].
///
/// The appearance and behavior of each item can be dynamically changed based
/// on its position in the wheel (e.g., if it's selected or how far it is from
/// the center) using the [CurvedListItemState] provided in the `itemBuilder`.
///
/// ## Key Features:
/// - **Curved Path Scrolling**: Items follow a quadratic Bézier curve.
/// - **Vertical & Horizontal Modes**: Controlled by the `side` parameter.
/// - **Infinite Scrolling**: Option to loop the list indefinitely.
/// - **Dynamic Item Styling**: `itemBuilder` provides state for conditional UI.
/// - **Rich Customization**: Use [CurvedListWheelSettings] to control item extent,
///   curve tightness, highlight box, and more.
/// - **Helper Widgets**: Includes [CurvedListWheelTextItem] for easy text styling.
///
/// ## Basic Usage:
///
/// A simple example displaying a list of planets.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:curved_list_wheel/curved_list_wheel.dart';
///
/// class PlanetPicker extends StatefulWidget {
///   @override
///   _PlanetPickerState createState() => _PlanetPickerState();
/// }
///
/// class _PlanetPickerState extends State<PlanetPicker> {
///   final _items = ['Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter'];
///   int _selectedIndex = 2;
///
///   @override
///   Widget build(BuildContext context) {
///     return CurvedListWheel<String>(
///       items: _items,
///       initialItem: _selectedIndex,
///       onSelectedItemChanged: (index) {
///         setState(() {
///           _selectedIndex = index;
///         });
///       },
///       itemBuilder: (context, index, item, itemState) {
///         // A helper widget is used here for simplicity, but you can build
///         // any custom widget.
///         return CurvedListWheelTextItem(
///           text: item,
///           itemState: itemState,
///           // Define styles for selected, unselected, and items at specific
///           // distances from the center.
///           style: const CurvedListWheelTextStyle(),
///         );
///       },
///     );
///   }
/// }
/// ```
class CurvedListWheel<T> extends StatefulWidget {
  /// The list of data items of type [T] to be displayed in the wheel.
  final List<T> items;

  /// A builder function that is called for each item to construct its widget.
  ///
  /// Provides the `BuildContext`, the `index` of the item, the `item` data,
  /// and a [CurvedListItemState] object which contains information about the
  /// item's current state (e.g., `isSelected`, `distance` from center).
  final Widget Function(BuildContext, int, T, CurvedListItemState) itemBuilder;

  /// An optional callback that is invoked when the centered item changes.
  ///
  /// It provides the index of the newly selected item in the `items` list.
  final ValueChanged<int>? onSelectedItemChanged;

  /// The index of the item that should be initially centered.
  ///
  /// Defaults to `0`. If the provided index is out of bounds, it will be
  /// clamped to the nearest valid index.
  final int initialItem;

  /// The scrolling physics for the list wheel.
  ///
  /// Defaults to [FixedExtentScrollPhysics], which snaps to items.
  final ScrollPhysics? physics;

  /// An optional controller to programmatically manage the scroll position.
  ///
  /// If null, a [FixedExtentScrollController] is created internally.
  final FixedExtentScrollController? controller;

  /// Configuration for the visual appearance of the list wheel.
  ///
  /// This includes settings for item extent, curve tightness, and the
  /// central highlight box. See [CurvedListWheelSettings] for details.
  final CurvedListWheelSettings settings;

  /// Determines whether the list should scroll infinitely.
  ///
  /// When `true`, the list wraps around, allowing endless scrolling.
  /// When `false`, the list has a start and an end. Defaults to `false`.
  final bool isInfinite;

  /// Defines the side on which the curve is drawn and the scroll axis.
  ///
  /// - [CurvedListWheelSide.left] (default): Vertical scroll, curve on the left.
  /// - [CurvedListWheelSide.right]: Vertical scroll, curve on the right.
  /// - [CurvedListWheelSide.top]: Horizontal scroll, curve on the top.
  /// - [CurvedListWheelSide.bottom]: Horizontal scroll, curve on the bottom.
  final CurvedListWheelSide side;

  /// Creates a scrollable list that moves items along a curved path.
  const CurvedListWheel({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onSelectedItemChanged,
    this.initialItem = 0,
    this.physics = const FixedExtentScrollPhysics(),
    this.controller,
    this.settings = const CurvedListWheelSettings(),
    this.isInfinite = false,
    this.side = CurvedListWheelSide.left,
  });

  @override
  State<CurvedListWheel<T>> createState() => _CurvedListWheelState<T>();
}

class _CurvedListWheelState<T> extends State<CurvedListWheel<T>> {
  late FixedExtentScrollController _scrollController;
  double _scrollOffset = 0.0;
  int _selectedIndex = 0;

  bool get _isHorizontal =>
      widget.side == CurvedListWheelSide.top ||
      widget.side == CurvedListWheelSide.bottom;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        (widget.initialItem >= 0 && widget.initialItem < widget.items.length)
            ? widget.initialItem
            : 0;
    _scrollController = widget.controller ??
        FixedExtentScrollController(initialItem: _selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CurvedListWheel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (widget.controller == null) {
        _scrollController.dispose();
        _scrollController =
            FixedExtentScrollController(initialItem: _selectedIndex);
      } else {
        _scrollController = widget.controller!;
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  double _calculateCurveDisplacement(double t, double crossAxisExtent) {
    final double p0 = -crossAxisExtent * widget.settings.pathCurveFactor;
    final double p1 = crossAxisExtent * widget.settings.pathCurveFactor;
    final double p2 = -crossAxisExtent * widget.settings.pathCurveFactor;

    return math.pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + math.pow(t, 2) * p2;
  }

  void _triggerHapticFeedback() {
    if (!widget.settings.enableHapticFeedback) {
      return;
    }
    switch (widget.settings.hapticFeedbackIntensity) {
      case HapticFeedbackIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackIntensity.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackIntensity.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackIntensity.vibrate:
        HapticFeedback.vibrate();
        break;
      case HapticFeedbackIntensity.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        final double highlightBoxMainExtent = widget.settings.itemExtent * 1.1;

        final double highlightBoxCrossExtent;
        if (_isHorizontal) {
          final factor = widget.settings.highlightHeightFactor ??
              widget.settings.highlightWidthFactor;
          highlightBoxCrossExtent = availableHeight * factor;
        } else {
          highlightBoxCrossExtent =
              availableWidth * widget.settings.highlightWidthFactor;
        }
        final double highlightBoxWidth =
            _isHorizontal ? highlightBoxMainExtent : highlightBoxCrossExtent;
        final double highlightBoxHeight =
            _isHorizontal ? highlightBoxCrossExtent : highlightBoxMainExtent;
        final double crossAxisExtent =
            _isHorizontal ? availableHeight : availableWidth;
        double curveCenterDisplacement =
            _calculateCurveDisplacement(0.5, crossAxisExtent);
        if (widget.side == CurvedListWheelSide.right ||
            widget.side == CurvedListWheelSide.bottom) {
          curveCenterDisplacement *= -1;
        }

        double highlightBoxLeft, highlightBoxTop;
        if (_isHorizontal) {
          highlightBoxLeft = (availableWidth / 2.0) - (highlightBoxWidth / 2.0);
          final double stackCenterY = availableHeight / 2.0;
          final double highlightBoxCenterY =
              stackCenterY + curveCenterDisplacement;
          highlightBoxTop = highlightBoxCenterY - (highlightBoxHeight / 2.0);
        } else {
          highlightBoxTop =
              (availableHeight / 2.0) - (highlightBoxHeight / 2.0);
          final double stackCenterX = availableWidth / 2.0;
          final double highlightBoxCenterX =
              stackCenterX + curveCenterDisplacement;
          highlightBoxLeft = highlightBoxCenterX - (highlightBoxWidth / 2.0);
        }

        final listWheel = ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: widget.settings.itemExtent,
          physics: widget.physics,
          onSelectedItemChanged: (index) {
            if (widget.items.isEmpty) return;

            final int effectiveIndex =
                widget.isInfinite ? index % widget.items.length : index;

            if (_selectedIndex == effectiveIndex) return;

            _triggerHapticFeedback();

            setState(() {
              _selectedIndex = effectiveIndex;
            });
            widget.onSelectedItemChanged?.call(effectiveIndex);
          },
          childDelegate: _buildItemDelegate(constraints),
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.settings.showHighlight)
              Positioned(
                left: highlightBoxLeft,
                top: highlightBoxTop,
                child: Container(
                  width: highlightBoxWidth,
                  height: highlightBoxHeight,
                  decoration: BoxDecoration(
                    color: widget.settings.highlightColor,
                    borderRadius: widget.settings.highlightBorderRadius ??
                        BorderRadius.circular(widget.settings.itemExtent),
                  ),
                ),
              ),
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  setState(() {
                    _scrollOffset = notification.metrics.pixels;
                  });
                }
                return true;
              },
              child: _isHorizontal
                  ? RotatedBox(quarterTurns: 1, child: listWheel)
                  : listWheel,
            ),
          ],
        );
      },
    );
  }

  ListWheelChildBuilderDelegate _buildItemDelegate(BoxConstraints constraints) {
    return ListWheelChildBuilderDelegate(
      childCount: widget.isInfinite ? null : widget.items.length,
      builder: (context, index) {
        if (widget.items.isEmpty) return const SizedBox.shrink();

        final int effectiveIndex =
            widget.isInfinite ? index % widget.items.length : index;

        final double scrollAxisExtent =
            _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        final double crossAxisExtent =
            _isHorizontal ? constraints.maxHeight : constraints.maxWidth;

        final itemPositionOnScrollAxis = index * widget.settings.itemExtent;
        final relativePositionOnScrollAxis =
            itemPositionOnScrollAxis - _scrollOffset;

        final double t =
            (relativePositionOnScrollAxis / (scrollAxisExtent / 2.0) + 1.0) /
                2.0;

        double displacement =
            _calculateCurveDisplacement(t.clamp(0.0, 1.0), crossAxisExtent);

        if (widget.side == CurvedListWheelSide.right ||
            widget.side == CurvedListWheelSide.bottom) {
          displacement *= -1;
        }

        final bool isSelected = (effectiveIndex == _selectedIndex);
        final int distance;
        if (widget.isInfinite) {
          final int listLength = widget.items.length;
          final int diff = (effectiveIndex - _selectedIndex).abs();
          distance = math.min(diff, listLength - diff);
        } else {
          distance = (index - _selectedIndex).abs();
        }

        final itemState =
            CurvedListItemState(isSelected: isSelected, distance: distance);

        final child = widget.itemBuilder(
          context,
          effectiveIndex,
          widget.items[effectiveIndex],
          itemState,
        );

        final Offset transformOffset =
            _isHorizontal ? Offset(0, displacement) : Offset(displacement, 0);

        Widget transformedChild = Transform.translate(
          offset: transformOffset,
          child: Center(child: child),
        );

        if (_isHorizontal) {
          transformedChild = RotatedBox(
            quarterTurns: -1,
            child: transformedChild,
          );
        }

        return transformedChild;
      },
    );
  }
}
