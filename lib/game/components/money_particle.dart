// Money-fly effect — ~6 coins arc from source to sink, then pop out.
//
// Used by the game whenever rent/tax/GO/card cash changes hands so the player
// sees where money is moving.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../art/coin_painter.dart';

class _CoinParticle extends PositionComponent {
  _CoinParticle({
    required Vector2 initialPosition,
    required Vector2 coinSize,
  }) : super(
          size: coinSize,
          position: initialPosition,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    const CoinPainter().paint(canvas, size.toSize());
  }
}

/// Spawns ~6 coin particles that arc from [from] to [to], then pop out.
/// Particles are approximated as a 3-segment polyline whose middle vertex is
/// lifted above the straight line to create the arc.
Future<void> spawnMoneyFly(
  FlameGame game, {
  required Vector2 from,
  required Vector2 to,
  int amountHint = 0,
}) async {
  final rng = math.Random();
  const count = 6;
  final host = game.world;

  for (var i = 0; i < count; i++) {
    final jitter = Vector2(
      (rng.nextDouble() - 0.5) * 14,
      (rng.nextDouble() - 0.5) * 14,
    );
    final start = from + jitter;
    final end = to +
        Vector2(
          (rng.nextDouble() - 0.5) * 14,
          (rng.nextDouble() - 0.5) * 14,
        );
    final midLift = 60 + rng.nextDouble() * 30;
    final mid1 = Vector2(
      start.x + (end.x - start.x) * 0.33,
      math.min(start.y, end.y) - midLift,
    );
    final mid2 = Vector2(
      start.x + (end.x - start.x) * 0.66,
      math.min(start.y, end.y) - midLift * 0.6,
    );

    final coin = _CoinParticle(
      initialPosition: start,
      coinSize: Vector2.all(18 + rng.nextDouble() * 6),
    );

    final delaySec = i * 0.06;
    coin.add(
      SequenceEffect([
        // Initial stagger delay.
        MoveEffect.by(Vector2.zero(), EffectController(duration: delaySec)),
        MoveEffect.to(mid1, EffectController(duration: 0.22)),
        MoveEffect.to(mid2, EffectController(duration: 0.22)),
        MoveEffect.to(end, EffectController(duration: 0.18)),
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.14)),
        RemoveEffect(),
      ]),
    );
    coin.add(
      RotateEffect.by(math.pi * 2, EffectController(duration: 0.7)),
    );

    host.add(coin);
  }
}
