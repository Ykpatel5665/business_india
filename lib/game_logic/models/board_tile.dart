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
}