import 'package:flutter/material.dart';
import 'app_theme.dart';

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

/// AvatarSelector: Horizontal list of selectable avatars.
///
/// Accessibility: Each avatar is a button with a semantic label.
class AvatarSelector extends StatelessWidget {
  final List<String> avatars;
  final int? selectedIndex;
  final double scale;
  final void Function(int) onAvatarTap;
  const AvatarSelector({
    super.key,
    required this.avatars,
    required this.selectedIndex,
    required this.scale,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: avatars.length + 2,
        separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
        itemBuilder: (context, index) {
          if (index == 0 || index == avatars.length + 1) {
            return SizedBox(width: 18 * scale);
          }
          final avatarIdx = index - 1;
          final isSelected = selectedIndex == avatarIdx;
          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Select avatar ${avatarIdx + 1}${isSelected ? ", selected" : ""}',
            child: GestureDetector(
              onTap: () => onAvatarTap(avatarIdx),
              child: AvatarDisplay(
                imagePath: avatars[avatarIdx],
                outerRadius: AppSpacing.avatarOuter(scale, selected: isSelected),
                innerRadius: AppSpacing.avatarInner(scale, selected: isSelected),
                showBorder: isSelected,
                borderColor: AppColors.avatarBorder,
                borderWidth: 2 * scale,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.avatarBorder.withOpacity(0.18),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

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

/// GameModeButton: Large, visually engaging button for game mode options.
///
/// Accessibility: Adds semantic label and selected state.
class GameModeButton extends StatelessWidget {
  final Color color; // Main color for the button (unique per mode)
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double scale;
  final bool selected;
  final String semanticLabel;
  final VoidCallback? onInfoTap; // Optional info/help button

  const GameModeButton({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.scale,
    required this.selected,
    required this.semanticLabel,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 2 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18 * scale),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? 0.28 : 0.13),
                blurRadius: selected ? 10 * scale : 6 * scale,
                offset: Offset(0, selected ? 5 * scale : 2 * scale),
              ),
            ],
            border: Border.all(
              color: selected ? color : color.withOpacity(0.5),
              width: selected ? 2.2 * scale : 1.1 * scale,
            ),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
                ),
                padding: EdgeInsets.symmetric(vertical: 8 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 26 * scale),
                    if (onInfoTap != null) ...[
                      SizedBox(width: 8 * scale),
                      GestureDetector(
                        onTap: onInfoTap,
                        child: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.85), size: 16 * scale),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge(scale * 0.95).copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1 * scale,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.13),
                        blurRadius: 2 * scale,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// UI components for Monopoly City will be implemented here.
