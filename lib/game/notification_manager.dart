import 'package:flutter/material.dart';
import 'monopoly_flame_game.dart';
import 'overlay_manager.dart';

class NotificationManager {
  final MonopolyFlameGame game;
  NotificationManager(this.game);

  final List<String> _notificationQueue = [];
  bool _notificationActive = false;

  void show(String message) {
    _notificationQueue.add(message);
    _tryShowNextNotification();
  }

  void _tryShowNextNotification() {
    if (_notificationActive || _notificationQueue.isEmpty) return;
    _notificationActive = true;
    final message = _notificationQueue.removeAt(0);
    game.overlays.add('Notification');
    game.overlayManager.addWidget(
      'Notification',
      Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            elevation: 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [
                  Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1)),
                ]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      game.overlays.remove('Notification');
      _notificationActive = false;
      _tryShowNextNotification();
    });
  }
}
