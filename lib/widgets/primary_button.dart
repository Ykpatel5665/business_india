import 'package:flutter/material.dart';
import '../app_theme.dart';

/// PrimaryButton: Styled action button.
///
/// Accessibility: Adds a semantic button label and disabled state.
class PrimaryButton extends StatelessWidget {
  final String label;
  final double scale;
  final VoidCallback? onTap;
  final bool enabled;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.scale,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingH(scale),
              vertical: AppSpacing.buttonPaddingV(scale),
            ),
            decoration: BoxDecoration(
              color: AppColors.button,
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: AppColors.avatarShadow.withOpacity(0.28),
                  offset: Offset(0, 4 * scale),
                  blurRadius: 10 * scale,
                ),
              ],
              border: Border.all(
                color: AppColors.button,
                width: 1.5 * scale,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.button(scale),
            ),
          ),
        ),
      ),
    );
  }
}
