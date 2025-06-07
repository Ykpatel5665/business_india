import 'package:flutter/material.dart';
import '../app_theme.dart';

/// CustomTextField: Styled text field for name input.
///
/// Accessibility: Adds a semantic text field label.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final double scale;
  final void Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.scale,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Enter your name',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.75),
          borderRadius: BorderRadius.circular(AppSpacing.fieldRadius(scale)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6 * scale,
              offset: Offset(0, 1 * scale),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10 * scale),
          ),
          style: AppTextStyles.bodyLarge(scale).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
