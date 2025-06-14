import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants/avatars.dart';
import '../game_logic/engine/game_engine.dart';
import 'monopoly_flame_game.dart';

class PlayerHudWidget extends PositionComponent {
  final GameEngine engine;
  PlayerHudWidget({required this.engine});

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);
    final width = 260.0;
    final height = 60.0 + 32.0 * engine.players.length;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(12),
      ),
      paint,
    );
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(canvas, 'Players', Vector2(12, 10));
    for (var i = 0; i < engine.players.length; i++) {
      final player = engine.players[i];
      final color = i == 0 ? Colors.red : Colors.blue;
      final playerText = '${player.name}:  \$${player.balance.toInt()}  (Pos: ${player.position})';
      final playerPaint = TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
      playerPaint.render(canvas, playerText, Vector2(16, 40 + i * 32));
    }
  }

  // Add a button to open the Trade Dialog (for demonstration, top right corner)
  @override
  void onMount() {
    super.onMount();
    // Only add the trade button once per mount
    if (parent is MonopolyFlameGame) {
      (parent as MonopolyFlameGame).addTradeButton();
    }
  }

  @override
  void onRemove() {
    // Remove the trade button overlay if the HUD is removed
    if (parent is MonopolyFlameGame) {
      (parent as MonopolyFlameGame).overlays.remove('TradeButton');
    }
    super.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < engine.players.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: i == engine.currentPlayerIndex ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(avatars[i % avatars.length]),
                      radius: 20,
                    ),
                    Text(engine.players[i].name),
                    Text('₹${engine.players[i].balance.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Optionally: add more HUD polish, e.g. animations, sound, or responsive layout here
}
