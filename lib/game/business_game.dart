// Business India — Flame game shell.
//
// Renders the board, tokens, and dice against a wooden-table background.
// Subscribes to GameController and reconciles visual state (positions,
// dice values, phase effects) whenever the controller notifies listeners.
//
// Coordinate system:
//   * BoardComponent uses a CENTERED local coord system (Anchor.center). Tile
//     positions come from `geometry.tileCenter(i)`, which returns coordinates
//     with (0,0) at the board center, +x right, +y down.
//   * Tokens and dice MUST be children of BoardComponent so they share the
//     same frame as the tiles. If you add them to `world` directly they end
//     up outside the board visual.
//   * The camera's viewfinder looks at world (0,0) with Anchor.center, which
//     is also where BoardComponent's centre sits.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../app/controllers/game_controller.dart';
import '../app/theme/game_colors.dart';
import '../game_logic/models/player.dart';
import 'art/wooden_table_painter.dart';
import 'components/board_component.dart';
import 'components/board_geometry.dart';
import 'components/confetti_effect.dart';
import 'components/dice_component.dart';
import 'components/money_particle.dart';
import 'components/token_component.dart';

class BusinessGame extends FlameGame with ScaleDetector {
  BusinessGame({required this.controller});

  final GameController controller;

  // Pure value type with a default constructor — safe to build eagerly. This
  // avoids LateInitializationError when Flame calls `onGameResize` BEFORE
  // `onLoad()` runs (a guaranteed part of Flame's mount pipeline).
  final BoardGeometry geometry = BoardGeometry();

  // Mounted components. Nullable on purpose: before `onLoad()` finishes
  // nothing is mounted, and any pre-load callback (resize, controller notify)
  // must no-op instead of touching them.
  BoardComponent? board;
  DiceComponent? dice;
  bool _loaded = false;

  /// Tokens keyed by their 1-based engine tokenId.
  final Map<int, TokenComponent> tokensByTokenId = {};

  /// Cached last-known engine positions so we know when to animate.
  final Map<int, int> _lastPositionByTokenId = {};

  // Confetti should fire once on game-over.
  bool _confettiFired = false;

  // Zoom state. NOTE: no hardcoded min — `_fitZoom` can return < 1.0 on
  // viewports narrower than the logical board (e.g. 320×568 phones). A tiny
  // absolute floor prevents degenerate cases during resize transitions.
  double _zoom = 1.0;
  double _zoomAtScaleStart = 1.0;
  static const double _absoluteMinZoom = 0.05;
  static const double _userMaxZoom = 3.0;

  @override
  Color backgroundColor() => GameColors.tableDark;

  @override
  Future<void> onLoad() async {
    // Wooden-table background. Rendered under the camera's backdrop so it
    // doesn't scale with world zoom.
    camera.backdrop.add(_WoodenBackdrop());

    // Board centered at world origin. All game children (tiles, tokens, dice)
    // live inside this component and share its centered local coord system.
    final boardComp = BoardComponent(
      geometry: geometry,
      engine: controller.engine,
      onTilePressed: _onTilePressed,
    )
      ..position = Vector2.zero()
      ..anchor = Anchor.center;
    board = boardComp;
    world.add(boardComp);

    // Dice: centered at the board's middle panel. BoardComponent's local
    // coord system runs 0..boardSize with origin top-left, so "centre" is
    // boardSize / 2.
    final diceComp = DiceComponent()
      ..position = geometry.boardCentre
      ..anchor = Anchor.center;
    dice = diceComp;
    boardComp.add(diceComp);

    // Tokens for every player. controller.engine throws if startGame() has
    // never been called — guard against that.
    if (controller.isReady) {
      final players = controller.engine.players;
      for (var i = 0; i < players.length; i++) {
        final p = players[i];
        final colorIdx = controller.colorIndexFor(p);
        final avatarIdx = controller.avatarIndexFor(p);
        final seat = _seatFor(p, players);
        final token = TokenComponent(
          tokenId: p.tokenId,
          seatColor: GameColors.playerColors[
              colorIdx.clamp(0, GameColors.playerColors.length - 1)],
          avatarIndex: avatarIdx,
          geometry: geometry,
          startTileIndex: p.position,
          seat: seat,
        );
        tokensByTokenId[p.tokenId] = token;
        _lastPositionByTokenId[p.tokenId] = p.position;
        // Tokens share the board's coordinate system: they must be children
        // of the board, not of the world.
        boardComp.add(token);
      }
    }

    // Camera: look at world origin (where the board sits), and center the
    // viewport around that point. This single setup works for every screen
    // aspect ratio — the viewfinder pins (0, 0) world to the middle of the
    // visible canvas.
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();
    _applyFitZoom();

    controller.addListener(_onControllerChanged);
    _loaded = true;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Flame fires onGameResize BEFORE onLoad — bail out until we're set up.
    if (!_loaded) return;
    _applyFitZoom();
  }

  void _applyFitZoom() {
    final fit = _fitZoom();
    _zoom = fit;
    camera.viewfinder.zoom = fit;
  }

  @override
  void onRemove() {
    controller.removeListener(_onControllerChanged);
    super.onRemove();
  }

  // ── Zoom ────────────────────────────────────────────────────────────────

  @override
  void onScaleStart(ScaleStartInfo info) {
    _zoomAtScaleStart = _zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final factor = info.raw.scale;
    final fit = _fitZoom();
    // User-driven zoom is clamped between the current fit (can't zoom out
    // past "see everything") and a 3× cap. This lets small viewports still
    // compute a fit < 1.0 but prevents the user from zooming out indefinitely.
    final target = (_zoomAtScaleStart * factor)
        .clamp(fit, fit * _userMaxZoom)
        .toDouble();
    _zoom = target;
    camera.viewfinder.zoom = target;
  }

  // ── Controller reconciliation ──────────────────────────────────────────

  void _onControllerChanged() {
    if (!_loaded || !controller.isReady) return;

    // Dice — set values directly; animation is triggered specifically by the
    // `rolling` phase transition.
    dice?.set(controller.lastDice1 == 0 ? 1 : controller.lastDice1,
        controller.lastDice2 == 0 ? 1 : controller.lastDice2);

    if (controller.phase == TurnPhase.rolling) {
      // Fire-and-forget: Flame's effect engine handles the animation.
      dice?.roll(controller.lastDice1, controller.lastDice2);
    }

    // Token positions.
    final players = controller.engine.players;
    for (final p in players) {
      final token = tokensByTokenId[p.tokenId];
      if (token == null) continue;
      final last = _lastPositionByTokenId[p.tokenId] ?? p.position;
      if (p.position != last) {
        _lastPositionByTokenId[p.tokenId] = p.position;
        final forwardSteps = (p.position - last + 40) % 40;
        if (forwardSteps > 0 && forwardSteps <= 12) {
          // Step-walk — normal dice move.
          token.moveTo(p.position);
        } else {
          // Large jump (card teleport, go-to-jail, etc.): snap instantly.
          token.snapTo(p.position);
        }
      }
      // Update the seat so stacked tokens spread apart.
      final newSeat = _seatFor(p, players);
      if (newSeat != token.seat) token.setSeat(newSeat);
    }

    // Board visual state (houses/hotels/mortgage).
    board?.syncFromEngine();

    // Win state — spawn confetti once.
    if (controller.phase == TurnPhase.gameOver && !_confettiFired) {
      _confettiFired = true;
      spawnConfetti(this);
    }
    if (controller.phase != TurnPhase.gameOver) {
      _confettiFired = false;
    }

    // Rent / tax visual: fly money from debtor to creditor (or to the
    // bank at the board center if no creditor).
    if (controller.phase == TurnPhase.rentDue && controller.toastPlayer != null) {
      _flyRentFromCurrentPlayer();
    }
  }

  void _flyRentFromCurrentPlayer() {
    final debtor = controller.currentPlayer;
    final debtorToken = tokensByTokenId[debtor.tokenId];
    if (debtorToken == null) return;
    final pos = controller.engine.board[debtor.position];
    final creditor = pos.property?.owner;
    final fromVec = debtorToken.position.clone();
    final toVec = creditor == null
        ? Vector2.zero()
        : (tokensByTokenId[creditor.tokenId]?.position.clone() ??
            Vector2.zero());
    spawnMoneyFly(this,
        from: fromVec, to: toVec, amountHint: controller.toastAmount ?? 0);
  }

  // ── Interaction ────────────────────────────────────────────────────────

  void _onTilePressed(int position) {
    // Currently tiles are passive — screen overlays react via the controller.
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Seat assignment: when multiple tokens share a tile, spread them across
  /// seats 0..5 in player-order so they don't overlap.
  int _seatFor(Player player, List<Player> allPlayers) {
    final onSameTile = <Player>[];
    for (final p in allPlayers) {
      if (p.position == player.position && !p.isBankrupt) onSameTile.add(p);
    }
    final idx = onSameTile.indexOf(player);
    return idx < 0 ? 0 : idx.clamp(0, 5);
  }

  /// Fluid fit: the board scales to the smaller canvas dimension. A small
  /// padding factor leaves breathing room so tiles don't kiss the viewport
  /// edges. This single formula handles every aspect ratio — phones in
  /// portrait, tablets in landscape, desktop drag-resize — without any
  /// device-specific branching.
  double _fitZoom() {
    final canvas = size;
    if (canvas.x <= 0 || canvas.y <= 0) return 1.0;
    final board = geometry.boardSize;
    const padding = 1.08; // 8% breathing room around the outer board edge
    final fit = math.min(canvas.x, canvas.y) / (board * padding);
    return fit < _absoluteMinZoom ? _absoluteMinZoom : fit;
  }
}

/// Paints the wooden table underneath the world. Sized to the viewport so it
/// always fills the screen regardless of zoom or pan.
class _WoodenBackdrop extends PositionComponent with HasGameReference<FlameGame> {
  @override
  void render(Canvas canvas) {
    final vp = game.camera.viewport.size;
    const painter = WoodenTablePainter();
    painter.paint(canvas, Size(vp.x, vp.y));
  }

  @override
  void update(double dt) {
    final vp = game.camera.viewport.size;
    if (size != vp) size = vp.clone();
  }
}
