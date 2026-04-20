import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/controllers/game_controller.dart';
import 'app/screens/game_screen.dart';
import 'app/screens/how_to_play_screen.dart';
import 'app/screens/menu_screen.dart';
import 'app/screens/player_setup_screen.dart';
import 'app/screens/settings_screen.dart';
import 'app/screens/splash_screen.dart';
import 'app/theme/game_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BusinessIndiaApp());
}

/// On web, `?autostart=1` (or `2`..`6` for N players) bypasses splash/menu/
/// setup and drops straight into GameScreen with a default roster. Used by
/// automated screenshot sweeps so we never have to drive the nav stack via
/// synthetic clicks, which are flaky on Flutter web.
int _autostartPlayers() {
  if (!kIsWeb) return 0;
  final q = Uri.base.queryParameters['autostart'];
  if (q == null) return 0;
  final n = int.tryParse(q);
  if (n == null) return q == '1' ? 2 : 0;
  return n.clamp(0, 6);
}

class BusinessIndiaApp extends StatelessWidget {
  const BusinessIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final autoN = _autostartPlayers();
    return ChangeNotifierProvider(
      create: (_) {
        final c = GameController();
        if (autoN >= 2) {
          c.startGame([
            for (var i = 0; i < autoN; i++)
              PlayerSlot(
                name: 'Player ${i + 1}',
                colorIndex: i,
                avatarIndex: i,
                isBot: i > 0,
              ),
          ]);
        }
        return c;
      },
      child: MaterialApp(
        title: 'Business India',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.light(),
        home: autoN >= 2 ? const GameScreen() : const SplashScreen(),
        routes: {
          MenuScreen.routeName: (_) => const MenuScreen(),
          PlayerSetupScreen.routeName: (_) => const PlayerSetupScreen(),
          HowToPlayScreen.routeName: (_) => const HowToPlayScreen(),
          SettingsScreen.routeName: (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
