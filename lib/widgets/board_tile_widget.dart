import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/enums.dart';

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
    final tileSize = 48.0;
    final borderRadius = tile.position % 10 == 0 ? 16.0 : 10.0;
    final elevation = tile.position % 10 == 0 ? 8.0 : 4.0;
    final shadowColor = Colors.black.withOpacity(0.18);
    final gradient = LinearGradient(
      colors: [Colors.white, Colors.grey[100]!, Colors.grey[200]!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Widget content;
    switch (tile.type) {
      case TileType.property:
        content = _PropertyTileWidget(tile: tile, onTap: onTap, tileSize: tileSize, borderRadius: borderRadius);
        break;
      default:
        content = _SimpleTileWidget(
          label: tile.label,
          icon: _getIconForTile(tile),
          color: _getColorForTile(tile),
          onTap: onTap,
          tileSize: tileSize,
          borderRadius: borderRadius,
        );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: tileSize,
      height: tileSize,
      margin: const EdgeInsets.all(2),
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
        border: Border.all(color: Colors.black, width: 2),
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

  Color _getColorForTile(BoardTile tile) {
    if (tile.property != null) {
      if (tile.property!.type == PropertyType.railroad) return Colors.black;
      if (tile.property!.type == PropertyType.utility) return Colors.yellow[800]!;
    }
    switch (tile.type) {
      case TileType.tax:
        return Colors.red[700]!;
      case TileType.jail:
        return Colors.orange[800]!;
      case TileType.chance:
        return Colors.purple[400]!;
      case TileType.communityChest:
        return Colors.blue[400]!;
      case TileType.go:
        return Colors.green[700]!;
      case TileType.freeParking:
        return Colors.blueGrey;
      case TileType.goToJail:
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }
}

/// Widget for property tiles (streets, with color bar and price).
class _PropertyTileWidget extends StatelessWidget {
  final BoardTile tile;
  final VoidCallback? onTap;
  final double tileSize;
  final double borderRadius;
  const _PropertyTileWidget({Key? key, required this.tile, this.onTap, required this.tileSize, required this.borderRadius}) : super(key: key);

  Color _getColor() {
    // UK edition color mapping
    const colors = [
      Color(0xFF8B4513), // Brown
      Color(0xFFADD8E6), // Light Blue
      Color(0xFFFF69B4), // Pink
      Color(0xFFFFA500), // Orange
      Color(0xFFDC143C), // Red
      Color(0xFFFFFF00), // Yellow
      Color(0xFF228B22), // Green
      Color(0xFF1E90FF), // Blue
      Colors.black, // Railroads
      Colors.grey,  // Utilities
    ];
    return colors[tile.property!.colorGroup % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final property = tile.property!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 10,
                width: tileSize - 12,
                decoration: BoxDecoration(
                  color: _getColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  property.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text('£${property.price.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
              if (property.type == PropertyType.railroad)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.train, size: 16, color: Colors.black),
                ),
              if (property.type == PropertyType.utility)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.flash_on, size: 16, color: Colors.yellow[800]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for non-property tiles (stations, utilities, tax, etc).
class _SimpleTileWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double tileSize;
  final double borderRadius;
  const _SimpleTileWidget({Key? key, required this.label, required this.icon, required this.color, this.onTap, required this.tileSize, required this.borderRadius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.10),
                Colors.white.withOpacity(0.85)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(tileSize * 0.10),
                child: Icon(icon, color: color, size: tileSize * 0.36),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: tileSize * 0.19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: Colors.black.withOpacity(0.85),
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.13),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
