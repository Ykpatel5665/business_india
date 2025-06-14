import 'package:flutter/material.dart';

/// MonopolyLogoWidget: Shows the Monopoly game logo in a game-like style.
/// Reusable and responsive for any screen.
class MonopolyLogoWidget extends StatelessWidget {
  const MonopolyLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/loginboard.png',
          height: MediaQuery.of(context).size.height * 0.18,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
