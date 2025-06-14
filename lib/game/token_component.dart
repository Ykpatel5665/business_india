import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// TokenComponent: Represents a player's token on the board, with animation.
class TokenComponent extends PositionComponent {
  final int playerIndex;
  int currentTile;
  final Color color;

  TokenComponent({
    required this.playerIndex,
    required this.currentTile,
    required this.color,
  }) : super(size: Vector2(36, 36));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // No sprite loading; use custom render only
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    // Optionally draw player index
    TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ).render(canvas, (playerIndex + 1).toString(), Vector2(10, 8));
  }

  /// Animate token movement to a new tile (by index, with board layout logic)
  Future<void> moveToTile(int tileIndex, Vector2 newPosition) async {
    currentTile = tileIndex;
    // Animate position to newPosition (can use effects or tween)
    add(MoveEffect.to(newPosition, EffectController(duration: 0.7, curve: Curves.easeInOut)));
  }
}
