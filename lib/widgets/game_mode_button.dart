import 'package:flutter/material.dart';
import '../app_theme.dart';

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
