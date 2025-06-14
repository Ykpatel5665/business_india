import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// AnimatedMoneyTransfer overlays a coin animation between two positions.
class AnimatedMoneyTransfer extends PositionComponent {
  AnimatedMoneyTransfer({
    required Vector2 from,
    required Vector2 to,
    double size = 32,
    double duration = 0.7,
    void Function()? onComplete,
  }) {
    final coin = SpriteComponent()
      ..size = Vector2.all(size)
      ..position = from;
    add(coin);
    Sprite.load('assets/coin.png').then((sprite) {
      coin.sprite = sprite;
    });
    coin.add(MoveEffect.to(
      to,
      EffectController(duration: duration, curve: Curves.easeInOut),
      onComplete: onComplete,
    ));
  }
}
