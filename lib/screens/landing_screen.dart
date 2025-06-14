import 'package:flutter/material.dart';
import '../screens/widgets/monopoly_logo_widget.dart';
import '../screens/widgets/animated_background_widget.dart';
import '../screens/widgets/main_action_buttons_widget.dart';
import '../screens/widgets/user_avatar_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive layout using LayoutBuilder
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB2FEFA), // Light blue
                  Color(0xFF0ED2F7), // Cyan
                  Color(0xFF4A90E2), // Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const AnimatedBackgroundWidget(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MonopolyLogoWidget(),
                const SizedBox(height: 32),
                const MainActionButtonsWidget(),
                const SizedBox(height: 32),
                const UserAvatarWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
