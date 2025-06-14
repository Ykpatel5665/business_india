import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// DiceComponent: Animated dice for Monopoly game.
class DiceComponent extends PositionComponent {
  int value;
  final void Function(int)? onRollComplete;
  bool _rolling = false;

  DiceComponent({
    this.value = 1,
    this.onRollComplete,
  }) : super(size: Vector2.all(48));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      border,
    );
    // Draw dice value (centered)
    TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ).render(canvas, value.toString(), Vector2(size.x / 2 - 10, size.y / 2 - 18));
  }

  /// Animate dice roll and update value
  Future<void> roll() async {
    if (_rolling) return;
    _rolling = true;
    final random = Random();
    int finalValue = value;
    for (int i = 0; i < 12; i++) {
      finalValue = random.nextInt(6) + 1;
      value = finalValue;
      await Future.delayed(const Duration(milliseconds: 40));
    }
    _rolling = false;
    onRollComplete?.call(finalValue);
  }
}
