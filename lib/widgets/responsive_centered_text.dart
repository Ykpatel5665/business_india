import 'package:flutter/material.dart';
import '../responsive_layout.dart';

/// A widget that displays a centered text for each device type using ResponsiveLayout.
class ResponsiveCenteredText extends StatelessWidget {
  final String mobileText;
  final String tabletText;
  final String desktopText;
  final TextStyle Function(double scale) styleBuilder;
  const ResponsiveCenteredText({
    super.key,
    required this.mobileText,
    required this.tabletText,
    required this.desktopText,
    required this.styleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Center(child: Text(mobileText, style: styleBuilder(1.0))),
      tablet: Center(child: Text(tabletText, style: styleBuilder(1.1))),
      desktop: Center(child: Text(desktopText, style: styleBuilder(1.3))),
    );
  }
}
