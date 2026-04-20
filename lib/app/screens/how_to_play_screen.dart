import 'package:flutter/material.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_panel.dart';
import 'backdrop.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});
  static const routeName = '/howto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.sunsetStart,
      body: SunsetBackdrop(
        floaters: false,
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.of(context).pop()),
              const Expanded(child: _Sections()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      child: Row(
        children: [
          CartoonButton(
            icon: Icons.arrow_back_rounded,
            color: GameColors.happyPurple,
            size: CartoonButtonSize.small,
            onPressed: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'How to Play',
              style: GameFonts.fredoka(
                size: 28,
                weight: FontWeight.w900,
                color: GameColors.white,
                shadows: const [
                  Shadow(
                    color: GameColors.outline,
                    offset: Offset(2, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections();

  static const _sections = <({IconData icon, Color color, String title, String body})>[
    (
      icon: Icons.casino_rounded,
      color: GameColors.happyRed,
      title: 'Roll the Dice',
      body:
          'Tap ROLL DICE on your turn. Your token hops around the board clockwise by the number you roll. Roll doubles? Go again! Three doubles in a row sends you to Jail.',
    ),
    (
      icon: Icons.home_rounded,
      color: GameColors.happyGreen,
      title: 'Buy Property',
      body:
          'Land on an unowned city and you can buy it at the printed price. Build houses and hotels on complete colour groups to charge huge rent. Decline, and it goes to auction.',
    ),
    (
      icon: Icons.currency_rupee_rounded,
      color: GameColors.happyYellow,
      title: 'Collect Rent',
      body:
          'Land on someone else\'s property and you pay rent — more if they\'ve built. Pass GO and collect ₹2,00,000. Railways and Utilities have their own rent rules.',
    ),
    (
      icon: Icons.shield_moon_rounded,
      color: GameColors.happyBlue,
      title: 'Stay Out of Jail',
      body:
          'Get sent to Jail by rolling three doubles, drawing "Go to Jail", or landing on Go to Jail. Pay ₹50,000 to leave, use a Get Out of Jail card, or roll doubles to escape.',
    ),
    (
      icon: Icons.shuffle_rounded,
      color: GameColors.happyPurple,
      title: 'Chance & Community Chest',
      body:
          'Land on one and draw a card. Could be a reward, a penalty, a trip across the board, or a Get Out of Jail Free card. Read it, tap OK, the effect happens.',
    ),
    (
      icon: Icons.handshake_rounded,
      color: GameColors.happyOrange,
      title: 'Trade & Manage',
      body:
          'Between turns, trade properties and cash with other players. Build houses (evenly across a group!), mortgage properties in a pinch, and plan your empire.',
    ),
    (
      icon: Icons.emoji_events_rounded,
      color: GameColors.gold,
      title: 'Bankrupt Everyone Else',
      body:
          'When a player can\'t pay, they\'re out. The last one standing wins the game. No mercy!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: _sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = _sections[i];
        return CartoonPanel(
          fill: GameColors.cream,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: CartoonShape.cartoonBox(
                  fill: s.color,
                  radius: CartoonShape.radiusSmall,
                  offset: 3,
                  borderWidth: 3,
                ),
                child: Icon(s.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: GameFonts.title()),
                    const SizedBox(height: 4),
                    Text(s.body, style: GameFonts.body()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
