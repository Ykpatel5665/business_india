import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../login_screen.dart';
import '../mode_selection_screen.dart';
import '../end_game_screen.dart';

class SplashOverlay extends StatelessWidget {
  const SplashOverlay({super.key});
  @override
  Widget build(BuildContext context) => const SplashScreen();
}

class LoginOverlay extends StatelessWidget {
  const LoginOverlay({super.key});
  @override
  Widget build(BuildContext context) => const LoginScreen();
}

class ModeSelectionOverlay extends StatelessWidget {
  const ModeSelectionOverlay({super.key});
  @override
  Widget build(BuildContext context) => const ModeSelectionScreen();
}

class EndGameOverlay extends StatelessWidget {
  const EndGameOverlay({super.key});
  @override
  Widget build(BuildContext context) => const EndGameScreen();
}
