import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'widgets/monopoly_game.dart';
import 'widgets/flame_overlays.dart';

void main() {
  runApp(const MonopolyFlameApp());
}

class MonopolyFlameApp extends StatelessWidget {
  const MonopolyFlameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly City',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: GameWidget(
          game: MonopolyGame(),
          overlayBuilderMap: {
            'splash': (ctx, game) => const SplashOverlay(),
            'login': (ctx, game) => const LoginOverlay(),
            'mode': (ctx, game) => const ModeSelectionOverlay(),
            'end': (ctx, game) => const EndGameOverlay(),
          },
          initialActiveOverlays: const ['splash'],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
