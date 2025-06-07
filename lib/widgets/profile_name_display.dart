import 'package:flutter/material.dart';
import '../app_theme.dart';

/// ProfileNameDisplay: Shows the user's name in a styled container.
///
/// Accessibility: Exposes the name as a semantic label.
class ProfileNameDisplay extends StatelessWidget {
  final String name;
  final double scale;
  const ProfileNameDisplay({super.key, required this.name, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name.isEmpty ? 'Profile name placeholder' : 'Profile name: $name',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Text(
          name.isEmpty ? 'Your Name' : name,
          style: AppTextStyles.bodyLarge(scale).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
