import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/enums.dart';
import 'board_tile_config.dart';

/// Widget to display a single Monopoly board tile.
/// Handles different tile types (property, station, utility, tax, etc).
class BoardTileWidget extends StatelessWidget {
  final BoardTile tile;
  final VoidCallback? onTap;
  const BoardTileWidget({Key? key, required this.tile, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    // All tiles (including corners) use the same size for perfect grid fit
    final tileSize = BoardTileConfig.tileSize;
    final borderRadius = BoardTileConfig.borderRadius;
    final elevation = tile.position % 10 == 0 ? BoardTileConfig.elevationCorner : BoardTileConfig.elevationNormal;
    final shadowColor = Colors.black.withOpacity(0.0);
    final gradient = BoardTileConfig.boardTileGradient;

    Widget content = _PropertyTileWidget(
        tile: tile,
        onTap: onTap,
        tileSize: tileSize,
        borderRadius: borderRadius,
      );
  
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: content,
    );
  }

  IconData _getIconForTile(BoardTile tile) {
    if (tile.property != null) {
      if (tile.property!.type == PropertyType.railroad) return Icons.train;
      if (tile.property!.type == PropertyType.utility) return Icons.flash_on;
    }
    switch (tile.type) {
      case TileType.tax:
        return Icons.attach_money;
      case TileType.jail:
        return Icons.gavel;
      case TileType.chance:
        return Icons.help;
      case TileType.communityChest:
        return Icons.card_giftcard;
      case TileType.go:
        return Icons.play_arrow;
      case TileType.freeParking:
        return Icons.local_parking;
      case TileType.goToJail:
        return Icons.lock;
      default:
        return Icons.crop_square;
    }
  }
}

/// Widget for property tiles (streets, with color bar and price).
class _PropertyTileWidget extends StatelessWidget {
  final BoardTile tile;
  final VoidCallback? onTap;
  final double tileSize;
  final double borderRadius;
  const _PropertyTileWidget({
    Key? key,
    required this.tile,
    this.onTap,
    required this.tileSize,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final property = tile.property;
    final bool isRow = tile.position <= 10 || (tile.position >= 20 && tile.position <= 30);
    final bool isColumn = !isRow;

    final List<Widget> widgets = [];
    final content = Expanded(
      child: Center(
        child: Transform.rotate(
          angle: (isRow ? 270 : 0) * (math.pi / 180),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  property?.name ?? tile.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '£${property?.price.toInt()}',
                style: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
              if (property?.type == PropertyType.railroad)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.train, size: 16, color: Colors.black),
                ),
              if (property?.type == PropertyType.utility)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.flash_on, size: 16, color: Colors.yellow[800]),
                ),
            ],
          ),
        ),
      ),
    );
    final Widget colorBar = Container(
      width: isRow ? double.infinity : 20,
      height: isRow ? 20 : double.infinity,
      decoration: BoxDecoration(
        color: BoardTileConfig.getBarColor(tile.property?.colorGroup),
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
    final Widget colorBar2 = Container(
      width: isRow ? double.infinity : 20,
      height: isRow ? 20 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
    if (tile.position < 11 || tile.position > 30) {
      widgets.add(colorBar);
    } else {
      widgets.add(colorBar2);
    }
    widgets.add(content);
    if (tile.position >= 11 && tile.position < 30) {
      widgets.add(colorBar);
    } else {
      widgets.add(colorBar2);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: isRow ? Column(children: widgets) : Row(children: widgets),
      ),
    );
  }
}
