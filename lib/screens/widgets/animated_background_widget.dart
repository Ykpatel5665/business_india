import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'cloud_widget.dart';

/// AnimatedBackgroundWidget: Layered animated clouds for a playful game background.
/// Reusable and composable for any Monopoly game screen.
class AnimatedBackgroundWidget extends StatelessWidget {
  const AnimatedBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CloudWidget(
          assetName: 'assets/cloud1.svg',
          width: 360,
          height: 180,
          opacity: 0.7,
          top: 0,
          leftBegin: -0.2,
          leftEnd: 1.2,
          durationSeconds: 20,
          speed: 1.0,
        ),
        CloudWidget(
          assetName: 'assets/cloud3.svg',
          width: 240,
          height: 120,
          opacity: 0.5,
          bottom: 50,
          rightBegin: -0.2,
          rightEnd: 1.2,
          durationSeconds: 25,
          speed: 0.7,
        ),
        // Add more CloudWidgets as needed
      ],
    );
  }
}
