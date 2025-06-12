import 'enums.dart';
import 'property.dart';
import 'package:flutter/material.dart';

/// Represents a tile on the Monopoly game board.
class BoardTile {
  final int position;
  final TileType type;
  final String label;
  final Property? property;
  final IconData? icon;
  final Color? color;

  BoardTile({
    required this.position,
    required this.type,
    required this.label,
    this.property,
    this.icon,
    this.color,
  });

  bool get isPropertyTile => type == TileType.property && property != null;
  bool get isOwnable => property != null;
  bool get isChanceTile => type == TileType.chance;
  bool get isCommunityChestTile => type == TileType.communityChest;
  bool get isGoTile => type == TileType.go;
  bool get isJailTile => type == TileType.jail;
  bool get isGoToJailTile => type == TileType.goToJail;
  bool get isTaxTile => type == TileType.tax;
  bool get isFreeParkingTile => type == TileType.freeParking;
}