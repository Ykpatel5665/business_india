import 'package:flutter/material.dart';

/// Use this widget to make your screens responsive across devices.
/// Example usage:
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(),
///   desktop: DesktopWidget(),
/// )
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
