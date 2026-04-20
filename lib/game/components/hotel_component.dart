// Hotel icon drawn via HotelPainter. Same drop-in animation as houses but
// slightly beefier because hotels feel like a bigger deal.
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../art/hotel_painter.dart';
import 'tile_component.dart';

class HotelComponent extends PositionComponent {
  HotelComponent({this.color = const Color(0xFFE63946)})
      : _painter = HotelPainter(color: color);

  final Color color;
  final HotelPainter _painter;

  @override
  Future<void> onLoad() async {
    addPopIn(this, duration: 0.32, overshoot: 1.25);
  }

  @override
  void onMount() {
    super.onMount();
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(0, -10), EffectController(duration: 0.15)),
        MoveEffect.by(Vector2(0, 10), EffectController(duration: 0.18)),
      ]),
    );
  }

  @override
  void render(Canvas canvas) {
    _painter.paint(canvas, size.toSize());
  }
}
