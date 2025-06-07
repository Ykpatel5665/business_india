import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import 'board_tile_widget.dart';

/// Widget to render the Monopoly board as a square grid.
/// Modular, ready for further interaction logic.
class MonopolyBoardWidget extends StatelessWidget {
  final List<BoardTile> boardTiles;
  final void Function(BoardTile)? onTileTap;
  const MonopolyBoardWidget({Key? key, required this.boardTiles, this.onTileTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Monopoly board is 40 tiles, arranged in a square (10 per side)
    // We'll use a Stack to arrange tiles in a square layout
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final tileSize = size / 11; // 10 tiles + 1 for corners
          List<Widget> positionedTiles = [];

          for (int i = 0; i < boardTiles.length; i++) {
            final tile = boardTiles[i];
            // Calculate position for each tile
            int x = 0, y = 0;
            if (i < 10) {
              // Bottom row, left to right
              x = 10 - i;
              y = 10;
            } else if (i < 20) {
              // Left column, bottom to top
              x = 0;
              y = 20 - i;
            } else if (i < 30) {
              // Top row, right to left
              x = i - 20;
              y = 0;
            } else {
              // Right column, top to bottom
              x = 10;
              y = i - 30;
            }
            positionedTiles.add(Positioned(
              left: x * tileSize,
              top: y * tileSize,
              width: tileSize,
              height: tileSize,
              child: BoardTileWidget(
                tile: tile,
                onTap: onTileTap != null ? () => onTileTap!(tile) : null,
              ),
            ));
          }

          return Stack(children: positionedTiles);
        },
      ),
    );
  }
}
