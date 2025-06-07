import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/responsive_centered_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ResponsiveCenteredText(
        mobileText: 'Splash Screen (Mobile)',
        tabletText: 'Splash Screen (Tablet)',
        desktopText: 'Splash Screen (Desktop)',
        styleBuilder: AppTextStyles.bodyLarge,
      ),
    );
  }
}
