import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import 'board_tile_widget.dart';

final double AspectRatio = 2;

/// Widget to render the Monopoly board with rectangular view.
/// First and last rows have bigger height, other rows have bigger width, corner grids remain square.
class MonopolyBoardWidget extends StatelessWidget {
  final List<BoardTile> boardTiles;
  final void Function(BoardTile)? onTileTap;
  final Widget? centerOverlay;
  const MonopolyBoardWidget({Key? key, required this.boardTiles, this.onTileTap, this.centerOverlay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize = (constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight) / (11 + (2 * (AspectRatio - 1)));
        double largeCellSize = cellSize * AspectRatio;

        return SizedBox(
          width: constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight,
          height: constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight,
          child: Stack(
            children: [
              ...List.generate(121, (index) {
                int row = index ~/ 11;
                int col = index % 11;
                int? tileIndex;

                // Bottom row (left to right)
                if (row == 10 && col >= 0 && col < 11) {
                  tileIndex = 10 - col;
                }
                // Left column (bottom to top)
                else if (col == 0 && row >= 0 && row < 11) {
                  tileIndex = 10 + (10 - row);
                }
                // Top row (right to left)
                else if (row == 0 && col >= 0 && col < 11) {
                  tileIndex = 20 + col;
                }
                // Right column (top to bottom)
                else if (col == 10 && row >= 0 && row < 11) {
                  tileIndex = 30 + row;
                }

                double left = col > 0 ? (largeCellSize + (col - 1) * cellSize) : 0.0;
                double top = row > 0 ? (largeCellSize + (row - 1) * cellSize) : 0.0;
                double width = (col == 0 || col == 10) ? largeCellSize : cellSize;
                double height = (row == 0 || row == 10) ? largeCellSize : cellSize;

                if (tileIndex != null && tileIndex >= 0 && tileIndex < boardTiles.length) {
                  final tile = boardTiles[tileIndex];
                  return Positioned(
                    left: left,
                    top: top,
                    width: width,
                    height: height,
                    child: BoardTileWidget(
                      tile: tile,
                      onTap: onTileTap != null ? () => onTileTap!(tile) : null,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              if (centerOverlay != null)
                Center(child: centerOverlay!),
            ],
          ),
        );
      },
    );
  }
}
