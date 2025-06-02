import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: Center(child: Text('Splash Screen (Mobile)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        tablet: Center(child: Text('Splash Screen (Tablet)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        desktop: Center(child: Text('Splash Screen (Desktop)', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
