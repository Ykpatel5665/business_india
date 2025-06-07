import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../constants/avatars.dart';
import 'avatar_display.dart';

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
            label: 'Select avatar ${avatarIdx + 1}${isSelected ? ", selected" : ""}',
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
