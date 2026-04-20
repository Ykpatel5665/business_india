import 'package:flutter/material.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import 'backdrop.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logo;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MenuScreen(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.sunsetStart,
      body: SunsetBackdrop(
        child: Center(
          child: AnimatedBuilder(
            animation: _logo,
            builder: (_, _) {
              final t = Curves.elasticOut.transform(_logo.value);
              return Transform.scale(
                scale: 0.5 + 0.5 * t,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Business',
                      style: GameFonts.logo(
                        size: 64,
                        fill: GameColors.happyYellow,
                        outline: GameColors.happyRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'India',
                      style: GameFonts.logo(
                        size: 80,
                        fill: GameColors.white,
                        outline: GameColors.happyPurple,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'The Ultimate Property Game',
                      style: GameFonts.nunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: GameColors.white,
                        style: FontStyle.italic,
                      ).copyWith(
                        shadows: const [
                          Shadow(
                            color: GameColors.outline,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
