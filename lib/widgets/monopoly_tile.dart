import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';

class MonopolyTile extends StatelessWidget {
  final BoardTile tile;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isCorner;

  const MonopolyTile({
    Key? key,
    required this.tile,
    required this.width,
    required this.height,
    this.onTap,
    this.isCorner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.all(isCorner ? width * 0.04 : width * 0.02),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(isCorner ? 16 : 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
          border: Border.all(color: theme.dividerColor, width: 2),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tile.icon != null) Icon(tile.icon, size: isCorner ? width * 0.4 : width * 0.3),
                  Text(
                    tile.label ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
