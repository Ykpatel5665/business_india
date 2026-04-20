// Confetti rain — ~100 pieces fall from above the viewport, drift sideways,
// tumble, and despawn after ~4 seconds. Used on game-over / win.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/theme/game_colors.dart';
import '../art/confetti_painter.dart';

class _ConfettiPiece extends PositionComponent {
  _ConfettiPiece({
    required Vector2 pieceSize,
    required Vector2 initialPosition,
    required this.color,
    required this.spin,
  }) : super(
          size: pieceSize,
          position: initialPosition,
          anchor: Anchor.center,
        );

  final Color color;
  final double spin; // rotation relative offset applied inside painter

  @override
  void render(Canvas canvas) {
    ConfettiPiecePainter(color: color, rotation: spin)
        .paint(canvas, size.toSize());
  }
}

/// Spawns 100 colored confetti rectangles falling from above the viewport.
/// Call on GameOver / win — particles self-despawn after ~4s.
void spawnConfetti(FlameGame game, {int count = 100}) {
  final rng = math.Random();
  final palette = <Color>[
    ...GameColors.playerColors,
    GameColors.gold,
    GameColors.cream,
    GameColors.happyPink,
    GameColors.happyTeal,
  ];

  // Use viewport size to decide spawn width; fall from above the screen.
  final vpSize = game.camera.viewport.size;
  final spawnWidth = vpSize.x + 200;
  final fallDistance = vpSize.y + 400;

  // Attach pieces to the viewport so they ignore world pan/zoom — falls are
  // screen-space, not board-space.
  final host = game.camera.viewport;

  for (var i = 0; i < count; i++) {
    final x = -100 + rng.nextDouble() * spawnWidth;
    final yStart = -80 - rng.nextDouble() * 200;
    final color = palette[rng.nextInt(palette.length)];
    final pieceSize = Vector2(
      10 + rng.nextDouble() * 10,
      5 + rng.nextDouble() * 5,
    );
    final drift =
        (rng.nextDouble() - 0.5) * 160; // sideways drift over the fall
    final duration = 2.8 + rng.nextDouble() * 1.4;
    final spin = rng.nextDouble() * math.pi * 2;

    final piece = _ConfettiPiece(
      pieceSize: pieceSize,
      initialPosition: Vector2(x, yStart),
      color: color,
      spin: spin,
    );

    piece.add(
      SequenceEffect([
        MoveEffect.to(
          Vector2(x + drift, yStart + fallDistance),
          EffectController(duration: duration),
        ),
        RemoveEffect(),
      ]),
    );
    // Continuous tumble.
    piece.add(
      RotateEffect.by(
        (rng.nextBool() ? 1 : -1) * math.pi * (2 + rng.nextDouble() * 4),
        EffectController(duration: duration),
      ),
    );

    host.add(piece);
  }
}
