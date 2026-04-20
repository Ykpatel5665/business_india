// Pair of 3D cartoon dice. Runs a brief spin + land sequence on roll and
// settles to the rolled values.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../art/dice_painter.dart';

class _SingleDie extends PositionComponent {
  _SingleDie() : super(size: Vector2.all(36), anchor: Anchor.center);

  int value = 1;
  bool _spinning = false;
  double _spinTimer = 0;
  final math.Random _rng = math.Random();

  Future<void> roll(int finalValue) async {
    _spinning = true;
    final endAngle = (_rng.nextDouble() * 0.6 - 0.3); // small rest tilt
    add(
      SequenceEffect([
        RotateEffect.by(math.pi * 4, EffectController(duration: 0.6)),
        RotateEffect.to(endAngle, EffectController(duration: 0.4)),
      ]),
    );
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(0, -14), EffectController(duration: 0.15)),
        MoveEffect.by(Vector2(0, 14), EffectController(duration: 0.18)),
        MoveEffect.by(Vector2(0, -6), EffectController(duration: 0.10)),
        MoveEffect.by(Vector2(0, 6), EffectController(duration: 0.10)),
      ]),
    );
    // Flip faces rapidly while spinning.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _spinning = false;
    value = finalValue;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_spinning) {
      _spinTimer += dt;
      if (_spinTimer > 0.05) {
        _spinTimer = 0;
        value = 1 + _rng.nextInt(6);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    DicePainter(value: value.clamp(1, 6)).paint(canvas, size.toSize());
  }
}

class DiceComponent extends PositionComponent {
  DiceComponent()
      : super(size: Vector2(80, 40), anchor: Anchor.center);

  // Instantiate eagerly so external `set()`/`roll()` calls during the brief
  // window before `onLoad()` mounts them never hit a late-init error.
  final _SingleDie _d1 = _SingleDie();
  final _SingleDie _d2 = _SingleDie();

  @override
  Future<void> onLoad() async {
    _d1.position = Vector2(22, 20);
    _d2.position = Vector2(size.x - 22, 20);
    add(_d1);
    add(_d2);
  }

  Future<void> roll(int v1, int v2) async {
    await Future.wait([_d1.roll(v1), _d2.roll(v2)]);
  }

  /// Snap values without animation (used when syncing to a non-animated state).
  void set(int v1, int v2) {
    _d1.value = v1.clamp(1, 6);
    _d2.value = v2.clamp(1, 6);
  }
}
