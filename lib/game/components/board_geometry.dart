// Board geometry for the 40-tile perimeter.
//
// Layout is the classic Monopoly square: 4 corner tiles (H x H) and 9 edge
// tiles (W x H) per side, so the total board is (2H + 9W) on each side.
// Tile indices run clockwise starting from the bottom-right corner (GO = 0)
// so that moving "forward" = incrementing the index.
import 'dart:math' as math;

import 'package:flame/components.dart';

/// Which edge of the board a tile sits on.
enum BoardEdge { bottom, left, top, right }

/// Pure geometry helper. Holds no Flame state; just math.
class BoardGeometry {
  BoardGeometry({this.cornerSide = 120, this.edgeWidth = 80});

  /// Size of a corner tile (square).
  final double cornerSide;

  /// Width of a regular edge tile (the long dimension is [cornerSide]).
  final double edgeWidth;

  /// Total board side length. Corner + 9 edges + corner = 2H + 9W.
  double get boardSize => 2 * cornerSide + 9 * edgeWidth;

  /// Half the board size — useful for centering around (0, 0).
  double get half => boardSize / 2;

  /// Classify a tile index 0..39 into an edge.
  BoardEdge edgeFor(int index) {
    assert(index >= 0 && index < 40);
    if (index == 0 || (index >= 1 && index <= 9)) return BoardEdge.bottom;
    if (index == 10 || (index >= 11 && index <= 19)) return BoardEdge.left;
    if (index == 20 || (index >= 21 && index <= 29)) return BoardEdge.top;
    return BoardEdge.right; // 30..39
  }

  bool isCorner(int index) =>
      index == 0 || index == 10 || index == 20 || index == 30;

  /// Tile size in local board units. Corners are square
  /// [cornerSide] × [cornerSide]. Edges are [edgeWidth] × [cornerSide]
  /// (long side perpendicular to the board edge).
  Vector2 tileSize(int index) {
    if (isCorner(index)) return Vector2.all(cornerSide);
    return Vector2(edgeWidth, cornerSide);
  }

  /// Returns the center of the tile in board-local coordinates.
  ///
  /// The board's local origin is TOP-LEFT — x grows right, y grows down, and
  /// every tile centre falls inside the 0..boardSize × 0..boardSize square.
  /// This matches Flame's PositionComponent child coordinate system, where
  /// child `position` is relative to the parent's top-left regardless of the
  /// parent's anchor.
  Vector2 tileCenter(int index) {
    final bs = boardSize;
    final c = cornerSide;
    switch (index) {
      case 0:
        // GO — bottom-right corner
        return Vector2(bs - c / 2, bs - c / 2);
      case 10:
        // Jail — bottom-left corner
        return Vector2(c / 2, bs - c / 2);
      case 20:
        // Free Parking — top-left corner
        return Vector2(c / 2, c / 2);
      case 30:
        // Go-to-Jail — top-right corner
        return Vector2(bs - c / 2, c / 2);
    }

    final edge = edgeFor(index);
    switch (edge) {
      case BoardEdge.bottom:
        // Index 1 sits one edge-slot LEFT of GO (bottom-right corner).
        final slot = index - 1; // 0..8
        final x = (bs - c) - (slot * edgeWidth + edgeWidth / 2);
        return Vector2(x, bs - c / 2);
      case BoardEdge.left:
        // Index 11 sits one edge-slot UP of Jail.
        final slot = index - 11;
        final y = (bs - c) - (slot * edgeWidth + edgeWidth / 2);
        return Vector2(c / 2, y);
      case BoardEdge.top:
        // Index 21 sits one edge-slot RIGHT of Free Parking.
        final slot = index - 21;
        final x = c + (slot * edgeWidth + edgeWidth / 2);
        return Vector2(x, c / 2);
      case BoardEdge.right:
        // Index 31 sits one edge-slot DOWN of Go-To-Jail.
        final slot = index - 31;
        final y = c + (slot * edgeWidth + edgeWidth / 2);
        return Vector2(bs - c / 2, y);
    }
  }

  /// Center point of the entire board (local coords).
  Vector2 get boardCentre => Vector2.all(boardSize / 2);

  /// Rotation (radians) of the tile contents so that text and the color
  /// strip face the board's interior.
  double tileAngle(int index) {
    switch (edgeFor(index)) {
      case BoardEdge.bottom:
        return 0.0;
      case BoardEdge.left:
        return math.pi / 2;
      case BoardEdge.top:
        return math.pi;
      case BoardEdge.right:
        return -math.pi / 2;
    }
  }

  /// Position inside a tile for one of up to 6 token seats. Seats are laid
  /// out in a 2×3 grid inside the tile's play area so tokens never overlap
  /// when multiple players share a tile.
  ///
  /// Returns BOARD-LOCAL coordinates.
  Vector2 tokenSpotOnTile(int index, int tokenSeat) {
    final seat = tokenSeat.clamp(0, 5);
    final center = tileCenter(index);
    final size = tileSize(index);

    final col = seat % 2; // 0 or 1
    final row = seat ~/ 2; // 0, 1, 2

    // Normalized seat positions inside the tile's own unrotated frame.
    const colSpread = 0.28;
    const rowSpread = 0.22;
    final nx = 0.5 + (col - 0.5) * colSpread;
    final ny = 0.55 + (row - 1) * rowSpread;

    final ux = (nx - 0.5) * size.x;
    final uy = (ny - 0.5) * size.y;

    final a = tileAngle(index);
    final cosA = math.cos(a);
    final sinA = math.sin(a);
    final rx = ux * cosA - uy * sinA;
    final ry = ux * sinA + uy * cosA;

    return Vector2(center.x + rx, center.y + ry);
  }

  /// Unit direction pointing from the tile edge (the color-strip side) into
  /// the center of the board — useful for drawing the strip on the correct
  /// side of the tile.
  Vector2 interiorDirection(int index) {
    switch (edgeFor(index)) {
      case BoardEdge.bottom:
        return Vector2(0, -1);
      case BoardEdge.left:
        return Vector2(1, 0);
      case BoardEdge.top:
        return Vector2(0, 1);
      case BoardEdge.right:
        return Vector2(-1, 0);
    }
  }
}
