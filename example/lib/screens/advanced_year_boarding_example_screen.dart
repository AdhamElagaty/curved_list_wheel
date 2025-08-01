import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:curved_list_wheel/curved_list_wheel.dart';

const Color _kPrimaryTextColor = Color(0xFF0D1113);
const Color _kAccentColor = Color(0xFF3EC1D3);
const Color _kInactiveDotColor = Color(0xFFE0E0E0);

class AdvancedYearBoardingExampleScreen extends StatefulWidget {
  const AdvancedYearBoardingExampleScreen({super.key});

  @override
  State<AdvancedYearBoardingExampleScreen> createState() =>
      _AdvancedYearBoardingExampleScreenState();
}

class _AdvancedYearBoardingExampleScreenState
    extends State<AdvancedYearBoardingExampleScreen> {
  late final List<int> _years;
  late final FixedExtentScrollController _scrollController;
  int _selectedYearIndex = 0;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();

    const int startYear = 1920;
    const int initialYear = 2003;
    final int currentYear = DateTime.now().year;

    _years = List<int>.generate(
      currentYear - startYear + 1,
      (index) => startYear + index,
    ).reversed.toList();

    _selectedYearIndex = _years.indexOf(initialYear);
    if (_selectedYearIndex == -1) _selectedYearIndex = 0;

    _scrollController =
        FixedExtentScrollController(initialItem: _selectedYearIndex);

    _scrollController.addListener(_updateRotation);
  }

  void _updateRotation() {
    const double rotationSensitivity = 0.008;
    final offset = _scrollController.offset;

    setState(() {
      _rotationAngle = offset * rotationSensitivity;
    });
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Center(child: Text(message, style: TextStyle(fontSize: 20))),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 140, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      backgroundColor: _kAccentColor.withValues(alpha: 0.4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  double _calculateHorizontalOffset(
      double t, double maxWidth, double curveFactor) {
    final double p0 = -maxWidth * curveFactor;
    final double p1 = maxWidth * curveFactor;
    final double p2 = -maxWidth * curveFactor;
    return math.pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + math.pow(t, 2) * p2;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateRotation);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = CurvedListWheelTextStyle(
      selectedStyle: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: _getResponsiveFontSize(context, 64, min: 48, max: 80),
        color: _kAccentColor,
      ),
      unselectedStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _getResponsiveFontSize(context, 32, min: 16, max: 40),
        color: _kPrimaryTextColor.withValues(alpha: 0.7),
      ),
      distanceSpecificStyles: {
        1: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: _getResponsiveFontSize(context, 32, min: 24, max: 50),
          color: _kPrimaryTextColor.withValues(alpha: 0.9),
        ),
        2: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: _getResponsiveFontSize(context, 32, min: 20, max: 45),
          color: _kPrimaryTextColor.withValues(alpha: 0.8),
        ),
      },
    );

    final settings = CurvedListWheelSettings(
      itemExtent: _getResponsiveSize(context, 65, min: 45, max: 85),
      highlightColor: _kAccentColor.withAlpha(38),
      highlightWidthFactor: 0.42,
      pathCurveFactor: 0.75,
      highlightBorderRadius: BorderRadius.circular(
        _getResponsiveSize(context, 25, min: 15, max: 35),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = MediaQuery.of(context).size;
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;
      
          final highlightBoxWidth =
              availableWidth * settings.highlightWidthFactor;
      
          final textPathCenterOffset = _calculateHorizontalOffset(
              0.5, availableWidth, settings.pathCurveFactor);
          final stackCenter = availableWidth / 2;
          final highlightBoxCenter = stackCenter + textPathCenterOffset;
      
          final highlightBoxLeft =
              highlightBoxCenter - (highlightBoxWidth / 1.5);
      
          final patternScale = screenSize.shortestSide / 360.0;
          final patternWidth = (310 * patternScale).clamp(200.0, 400.0);
          final patternLeft = highlightBoxLeft - (patternWidth * 0.96);
          final patternTop = ((availableHeight * 0.70 - patternWidth) / 2) +
              availableHeight * 0.30;
      
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              Positioned(
                left: patternLeft,
                top: patternTop,
                child: RotatingPattern(
                  rotationAngle: _rotationAngle,
                  width: patternWidth,
                ),
              ),
              SizedBox(
                height: availableHeight * 0.35,
                child: Column(
                  children: [
                    Spacer(),
                    const OnBoardingHeaderWidget(
                      title: "Let's get to\nknow you",
                      subtitle: 'Select your birth year',
                      totalProgressDots: 5,
                      activeProgressDots: 2,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  height: availableHeight * 0.70,
                  child: CurvedListWheel<int>(
                    items: _years,
                    controller: _scrollController,
                    settings: settings,
                    isInfinite: true,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYearIndex = index;
                      });
                    },
                    itemBuilder: (context, index, year, itemState) {
                      return CurvedListWheelTextItem(
                        text: year.toString(),
                        itemState: itemState,
                        style: textStyle,
                      );
                    },
                  ),
                ),
              ),
              NextButton(onPressed: () {
                _showCustomSnackBar(
                  context,
                  '${_years[_selectedYearIndex]}',
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class OnBoardingHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalProgressDots;
  final int activeProgressDots;

  const OnBoardingHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totalProgressDots,
    required this.activeProgressDots,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.06,
        right: screenWidth * 0.06,
        top: _getResponsiveSpacing(context, 16, min: 8, max: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 45, min: 24, max: 48),
              fontWeight: FontWeight.bold,
              color: _kPrimaryTextColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context, 12, min: 6, max: 18)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 25, min: 12, max: 28),
              color: _kPrimaryTextColor.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(
              height: _getResponsiveSpacing(context, 24, min: 12, max: 36)),
          Row(
            children: List.generate(totalProgressDots, (index) {
              final dotSize = _getResponsiveSize(context, 12, min: 8, max: 16);
              return Container(
                width: dotSize,
                height: dotSize,
                margin: EdgeInsets.only(
                    right: _getResponsiveSpacing(context, 10, min: 6, max: 14)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < activeProgressDots
                      ? _kAccentColor
                      : _kInactiveDotColor,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class RotatingPattern extends StatelessWidget {
  final double rotationAngle;
  final double width;

  const RotatingPattern({
    super.key,
    required this.rotationAngle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Image.asset(
        'assets/rounded_pattern.png',
        width: width,
        height: width,
        fit: BoxFit.cover,
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Positioned(
      bottom: _getResponsiveSpacing(context, 32, min: 20, max: 48),
      right: screenWidth * 0.06,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kAccentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccentColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(
                _getResponsiveSize(context, 22, min: 18, max: 28)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
            minimumSize: Size(
              _getResponsiveSize(context, 220, min: 48, max: 100),
              _getResponsiveSize(context, 64, min: 48, max: 80),
            ),
            elevation: 8,
            shadowColor: _kAccentColor.withAlpha(102),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: _getResponsiveSize(context, 24, min: 20, max: 32),
          ),
        ),
      ),
    );
  }
}

double _getResponsiveFontSize(BuildContext context, double baseSize,
    {double min = 12.0, double max = 80.0}) {
  final screenSize = MediaQuery.of(context).size;
  final scale = screenSize.shortestSide / 360.0;
  return (baseSize * scale).clamp(min, max);
}

double _getResponsiveSpacing(BuildContext context, double baseSpacing,
    {double min = 4.0, double max = 100.0}) {
  final heightScale = MediaQuery.of(context).size.height / 800.0;
  return (baseSpacing * heightScale).clamp(min, max);
}

double _getResponsiveSize(BuildContext context, double baseSize,
    {double min = 10.0, double max = 200.0}) {
  final scale = MediaQuery.of(context).size.shortestSide / 360.0;
  return (baseSize * scale).clamp(min, max);
}
