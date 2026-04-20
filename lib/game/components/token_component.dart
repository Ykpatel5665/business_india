// Player token. Renders via TokenPainter, gently bobs in idle state, and
// animates along the board path (one tile per step, tiny hop, squash on
// landing) when the controller asks us to move.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../art/token_painter.dart';
import 'board_geometry.dart';

class TokenComponent extends PositionComponent {
  TokenComponent({
    required this.tokenId,
    required this.seatColor,
    required this.avatarIndex,
    required this.geometry,
    required int startTileIndex,
    required int seat,
  })  : _tileIndex = startTileIndex,
        _seat = seat,
        super(
          size: Vector2.all(36),
          anchor: Anchor.center,
        );

  final int tokenId;
  final Color seatColor;
  final int avatarIndex;
  final BoardGeometry geometry;

  int _tileIndex;
  int _seat; // 0..5 — used for 2x3 grid placement when multiple share a tile
  double _idlePhase = 0;
  bool _moving = false;

  /// Current tile index the token is visually sitting on.
  int get tileIndex => _tileIndex;
  int get seat => _seat;

  @override
  Future<void> onLoad() async {
    position = geometry.tokenSpotOnTile(_tileIndex, _seat);
  }

  void setSeat(int seat) {
    _seat = seat.clamp(0, 5);
    if (!_moving) {
      position = geometry.tokenSpotOnTile(_tileIndex, _seat);
    }
  }

  /// Snap without animation (used after a card teleport when we don't want
  /// to animate every intermediate step).
  void snapTo(int tileIndex) {
    _tileIndex = tileIndex;
    position = geometry.tokenSpotOnTile(_tileIndex, _seat);
  }

  /// Animate through tiles [current+1, ..., target] (wrapping through 39→0).
  /// Returns a Future that completes when the whole sequence finishes.
  Future<void> moveTo(int targetTileIndex,
      {double stepDuration = 0.15}) async {
    if (_moving) return;
    if (targetTileIndex == _tileIndex) return;
    _moving = true;

    final steps = <int>[];
    var cursor = _tileIndex;
    while (cursor != targetTileIndex) {
      cursor = (cursor + 1) % 40;
      steps.add(cursor);
    }

    final effects = <Effect>[];
    for (final next in steps) {
      final to = geometry.tokenSpotOnTile(next, _seat);
      effects.add(
        MoveEffect.to(to, EffectController(duration: stepDuration)),
      );
    }
    // Squash and stretch on final landing.
    effects.add(
      ScaleEffect.to(
        Vector2(1.3, 0.8),
        EffectController(duration: 0.09),
      ),
    );
    effects.add(
      ScaleEffect.to(
        Vector2(1.0, 1.0),
        EffectController(duration: 0.09),
      ),
    );

    final seq = SequenceEffect(effects);
    add(seq);

    // Update logical index as we go so re-entrance events line up. We flip
    // incrementally in a simple polling loop — Flame effects don't expose a
    // per-step callback in a version-safe way.
    final totalDuration = stepDuration * steps.length + 0.18;
    final perStepTicks = (stepDuration * 1000).toInt();
    // Fire-and-forget micro-timer loop that bumps _tileIndex visually so
    // other components reading it during movement see plausible values.
    () async {
      for (final next in steps) {
        await Future<void>.delayed(Duration(milliseconds: perStepTicks));
        _tileIndex = next;
      }
    }();

    await Future<void>.delayed(
      Duration(milliseconds: (totalDuration * 1000).toInt()),
    );
    _tileIndex = targetTileIndex;
    _moving = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_moving) {
      // Idle bob: ~±2 units on y, 1.5s period.
      _idlePhase = (_idlePhase + dt) % 10;
      final bob = math.sin(_idlePhase * math.pi * 2 / 1.5) * 2;
      final anchorPos = geometry.tokenSpotOnTile(_tileIndex, _seat);
      position = Vector2(anchorPos.x, anchorPos.y + bob);
    }
  }

  @override
  void render(Canvas canvas) {
    TokenPainter(color: seatColor, faceVariant: avatarIndex)
        .paint(canvas, size.toSize());
  }
}
