import 'package:flutter/material.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';
import 'cartoon_button.dart';
import 'cartoon_panel.dart';

/// Drop-in replacement for [AlertDialog]. The panel bounces in with an
/// elastic scale curve — feels like a game dialog, not a system alert.
class CartoonDialog extends StatelessWidget {
  const CartoonDialog({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.icon,
    this.headerColor = GameColors.happyOrange,
    this.maxWidth = 420,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final IconData? icon;
  final Color headerColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 380),
        curve: Curves.elasticOut,
        tween: Tween(begin: 0.4, end: 1),
        builder: (_, t, child) => Transform.scale(scale: t, child: child),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CartoonPanel(
            fill: GameColors.cream,
            padding: EdgeInsets.zero,
            radius: CartoonShape.radiusLarge,
            offset: CartoonShape.shadowLarge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header strip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(CartoonShape.radiusLarge - 4)),
                    border: Border(
                      bottom: BorderSide(
                          color: GameColors.darken(headerColor, 0.25),
                          width: CartoonShape.borderMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: GameFonts.buttonLabel(
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DefaultTextStyle(
                    style: GameFonts.body(),
                    child: body,
                  ),
                ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          actions[i],
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Convenience for a simple OK dialog.
  static Future<void> alert(BuildContext context,
      {required String title,
      required String message,
      Color headerColor = GameColors.happyOrange}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CartoonDialog(
        title: title,
        headerColor: headerColor,
        body: Text(message, style: GameFonts.body()),
        actions: [
          CartoonButton(
            label: 'OK',
            color: GameColors.happyGreen,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
