import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:curved_list_wheel/curved_list_wheel.dart';

void main() {
  final List<String> testItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  Widget buildTestableWidget({
    required List<String> items,
    int initialItem = 0,
    ValueChanged<int>? onSelectedItemChanged,
    CurvedListWheelSettings settings = const CurvedListWheelSettings(),
    CurvedListWheelTextStyle textStyle = const CurvedListWheelTextStyle(),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CurvedListWheel<String>(
          items: items,
          initialItem: initialItem,
          onSelectedItemChanged: onSelectedItemChanged,
          settings: settings,
          itemBuilder: (context, index, item, itemState) {
            return CurvedListWheelTextItem(
              text: item,
              itemState: itemState,
              style: textStyle,
            );
          },
        ),
      ),
    );
  }

  group('CurvedListWheel', () {
    testWidgets('renders correctly and shows the initial item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          items: testItems,
          initialItem: 2,
        ),
      );

      expect(find.byType(CurvedListWheel<String>), findsOneWidget);

      expect(find.text('Item 3'), findsOneWidget);

      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('scrolling updates the selected item and triggers callback', (
      WidgetTester tester,
    ) async {
      int? updatedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          items: testItems,
          initialItem: 1,
          onSelectedItemChanged: (index) {
            updatedIndex = index;
          },
        ),
      );

      expect(find.text('Item 2'), findsOneWidget);
      expect(updatedIndex, isNull);

      final listWheel = find.byType(ListWheelScrollView);
      expect(listWheel, findsOneWidget);

      await tester.drag(listWheel, const Offset(0, -65.0));

      await tester.pumpAndSettle();

      expect(find.text('Item 3'), findsOneWidget);

      expect(updatedIndex, 2);
    });

    testWidgets(
      'applies correct text styles for selected and unselected items',
      (WidgetTester tester) async {
        const selectedStyle = TextStyle(fontSize: 30, color: Colors.red);
        const unselectedStyle = TextStyle(fontSize: 15, color: Colors.blue);

        await tester.pumpWidget(
          buildTestableWidget(
            items: testItems,
            initialItem: 2,
            textStyle: const CurvedListWheelTextStyle(
              selectedStyle: selectedStyle,
              unselectedStyle: unselectedStyle,
              distanceSpecificStyles: {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        final selectedTextStyleWidget = tester.widget<AnimatedDefaultTextStyle>(
          find
              .ancestor(
                of: find.text('Item 3'),
                matching: find.byType(AnimatedDefaultTextStyle),
              )
              .first,
        );

        final unselectedTextStyleWidget = tester
            .widget<AnimatedDefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('Item 2'),
                    matching: find.byType(AnimatedDefaultTextStyle),
                  )
                  .first,
            );

        expect(selectedTextStyleWidget.style.color, selectedStyle.color);
        expect(selectedTextStyleWidget.style.fontSize, selectedStyle.fontSize);

        expect(unselectedTextStyleWidget.style.color, unselectedStyle.color);
        expect(
          unselectedTextStyleWidget.style.fontSize,
          unselectedStyle.fontSize,
        );
      },
    );

    testWidgets('hides highlight box when showHighlight is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          items: testItems,
          settings: const CurvedListWheelSettings(showHighlight: true),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.child is Container,
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          items: testItems,
          settings: const CurvedListWheelSettings(showHighlight: false),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.child is Container,
        ),
        findsNothing,
      );
    });
  });
}
