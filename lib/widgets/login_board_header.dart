import 'package:flutter/material.dart';
import '../app_theme.dart';

/// LoginBoardHeader: Consistent header image for login and mode selection screens.
///
/// Accessibility: Adds semantic label for the header image.
class LoginBoardHeader extends StatelessWidget {
  final double maxContentWidth;
  final double scale;
  const LoginBoardHeader({super.key, required this.maxContentWidth, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Game login board header',
      image: true,
      child: Padding(
        padding: EdgeInsets.only(
          top: 48.0 * scale,
          bottom: 12.0 * scale,
        ),
        child: Image.asset(
          'assets/loginboard.png',
          width: (maxContentWidth * 0.85).clamp(160.0, maxContentWidth),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
