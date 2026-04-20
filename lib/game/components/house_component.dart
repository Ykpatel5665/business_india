// Tiny house icon drawn via HousePainter. Pops in with a scale bounce when
// first mounted so new improvements feel tactile.
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../art/house_painter.dart';
import 'tile_component.dart';

class HouseComponent extends PositionComponent {
  HouseComponent({this.roofColor = const Color(0xFFE63946),
      this.bodyColor = const Color(0xFF43AA46)})
      : _painter = HousePainter(
          roofColor: roofColor,
          bodyColor: bodyColor,
        );

  final Color roofColor;
  final Color bodyColor;
  final HousePainter _painter;

  @override
  Future<void> onLoad() async {
    addPopIn(this);
  }

  @override
  void onMount() {
    super.onMount();
    // Subtle vertical drop to pair with the scale pop.
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(0, -6), EffectController(duration: 0.12)),
        MoveEffect.by(Vector2(0, 6), EffectController(duration: 0.14)),
      ]),
    );
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, size.toSize());
  }
}
