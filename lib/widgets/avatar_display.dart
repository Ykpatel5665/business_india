import 'package:flutter/material.dart';
import '../app_theme.dart';

/// AvatarDisplay: Shows a circular avatar, optionally with a border and shadow.
///
/// Accessibility: Adds semantic label for screen readers.
class AvatarDisplay extends StatelessWidget {
  final String imagePath;
  final double outerRadius;
  final double innerRadius;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const AvatarDisplay({
    super.key,
    required this.imagePath,
    required this.outerRadius,
    required this.innerRadius,
    this.showBorder = false,
    this.borderColor = Colors.transparent,
    this.borderWidth = 2.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'User avatar',
      image: true,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder ? Border.all(color: AppColors.avatarBorder, width: borderWidth) : null,
          boxShadow: boxShadow,
        ),
        child: CircleAvatar(
          radius: outerRadius,
          backgroundColor: AppColors.card,
          child: CircleAvatar(
            radius: innerRadius,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
      ),
    );
  }
}
