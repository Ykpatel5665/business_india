import 'package:flutter/material.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/enums.dart';


/// Configuration and constants for BoardTileWidget and related widgets.
class BoardTileConfig {
  static const double tileSize = 48.0;
  static const double borderRadius = 0.0;
  static const double elevationCorner = 8.0;
  static const double elevationNormal = 4.0;

  static const List<Color> propertyColors = [
    Color(0xFF8B4513), // Brown
      Color(0xFFADD8E6), // Light Blue
      Color(0xFFFF69B4), // Pink
      Color(0xFFFFA500), // Orange
      Color(0xFFDC143C), // Red
      Color(0xFFFFFF00), // Yellow
      Color(0xFF228B22), // Green
      Color(0xFF1E90FF), // Blue
      Colors.transparent, // Railroads
      Colors.grey, // Utilities
  ];

  static Color getBarColor(int? colorGroup) {
    if (colorGroup == null) {
      return Colors.transparent;
    }
    // Use config propertyColors
    return BoardTileConfig.propertyColors[colorGroup % BoardTileConfig.propertyColors.length];
  }

  static const LinearGradient boardTileGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getTileColor(BoardTile tile) {
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
