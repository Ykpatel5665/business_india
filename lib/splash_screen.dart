import 'dart:async';
import 'package:flutter/material.dart';
import 'responsive_layout.dart';
import 'app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('SplashScreen: Timer started');
    Timer(const Duration(seconds: 2), () {
      print('SplashScreen: Timer ended, navigating to login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: Center(child: Text('Splash Screen (Mobile)', style: AppTextStyles.bodyLarge(1.0))),
        tablet: Center(child: Text('Splash Screen (Tablet)', style: AppTextStyles.titleLarge(1.1))),
        desktop: Center(child: Text('Splash Screen (Desktop)', style: AppTextStyles.titleLarge(1.3))),
      ),
    );
  }
}
