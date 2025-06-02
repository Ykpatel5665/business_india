import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'splash_screen.dart';
import 'mode_selection_screen.dart';
import 'player_selection_screen.dart';
import 'game_board_screen.dart';
import 'end_game_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MonopolyCityApp());
}

class MonopolyCityApp extends StatelessWidget {
  const MonopolyCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monopoly City',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/mode': (context) => const ModeSelectionScreen(),
        '/player': (context) => const PlayerSelectionScreen(),
        '/game': (context) => const GameBoardScreen(),
        '/end': (context) => const EndGameScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monopoly City'),
      ),
      body: ResponsiveLayout(
        mobile: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mode'),
              child: const Text('Start Game'),
            ),
          ],
        ),
        tablet: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mode'),
              child: const Text('Start Game'),
            ),
          ],
        ),
        desktop: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mode'),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
