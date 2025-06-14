import 'package:flutter/material.dart';

/// UserAvatarWidget: Displays a player's avatar and name in a game-like style.
/// Reusable for any player or user display in the Monopoly game.
class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage('assets/avatar1.png'),
        ),
        const SizedBox(height: 8),
        Text(
          'Player 1',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
