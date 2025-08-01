import 'package:flutter/material.dart';
import 'package:curved_list_wheel/curved_list_wheel.dart';

class TextExampleScreen extends StatefulWidget {
  const TextExampleScreen({super.key});

  @override
  State<TextExampleScreen> createState() => _TextExampleScreenState();
}

class _TextExampleScreenState extends State<TextExampleScreen> {
  final List<String> _items = [
    'Mercury',
    'Venus',
    'Earth',
    'Mars',
    'Jupiter',
    'Saturn',
    'Uranus',
    'Neptune',
  ];
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    const textStyle = CurvedListWheelTextStyle(
      selectedStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
      unselectedStyle: TextStyle(
        fontSize: 18,
        color: Colors.black54,
        fontWeight: FontWeight.w400,
      ),
      distanceSpecificStyles: {
        1: TextStyle(
          fontSize: 22,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        2: TextStyle(
          fontSize: 20,
          color: Colors.black45,
          fontWeight: FontWeight.w500,
        ),
      },
    );

    final settings = CurvedListWheelSettings(
      itemExtent: 80.0,
      highlightColor: Colors.deepPurple.withValues(alpha: 0.1),
      highlightWidthFactor: 0.3,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('CurvedListWheel Example'),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                const Text(
                  'Selected Planet:',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _items[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CurvedListWheel<String>(
              items: _items,
              initialItem: _selectedIndex,
              settings: settings,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index, item, itemState) {
                return CurvedListWheelTextItem(
                  text: item,
                  itemState: itemState,
                  style: textStyle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
