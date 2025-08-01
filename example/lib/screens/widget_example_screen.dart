import 'package:flutter/material.dart';
import 'package:curved_list_wheel/curved_list_wheel.dart';

class WidgetExampleScreen extends StatefulWidget {
  const WidgetExampleScreen({super.key});

  @override
  State<WidgetExampleScreen> createState() => _WidgetExampleScreenState();
}

class _WidgetExampleScreenState extends State<WidgetExampleScreen> {
  final List<Widget> _items = [
    _buildPlanetWidget(icon: Icons.public, text: 'Earth'),
    _buildPlanetWidget(icon: Icons.wb_sunny, text: 'Mercury'),
    _buildPlanetWidget(icon: Icons.local_fire_department, text: 'Mars'),
    _buildPlanetWidget(icon: Icons.ac_unit, text: 'Uranus'),
    _buildPlanetWidget(icon: Icons.circle, text: 'Jupiter'),
    _buildPlanetWidget(icon: Icons.satellite_alt, text: 'Saturn'),
  ];

  int _selectedIndex = 2;

  static Widget _buildPlanetWidget(
      {required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.indigo, size: 30),
          const SizedBox(width: 12),
          Text(text,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = CurvedListWheelSettings(
        itemExtent: 100.0, showHighlight: false, pathCurveFactor: 0.85);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Widget Example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                const Text(
                  'Selected Widget',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                _items[_selectedIndex],
              ],
            ),
          ),
          Expanded(
            child: CurvedListWheel<Widget>(
              items: _items,
              initialItem: _selectedIndex,
              settings: settings,
              side: CurvedListWheelSide.right,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index, item, itemState) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: itemState.isSelected ? 1.0 : 0.4,
                  child: item,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
