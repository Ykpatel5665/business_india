import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'responsive_layout.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _CheckeredBackground(
        child: ResponsiveLayout(
          mobile: _ModeSelectionContent(maxWidth: 420),
          tablet: Center(child: SizedBox(width: 500, child: _ModeSelectionContent(maxWidth: 500))),
          desktop: Center(child: SizedBox(width: 600, child: _ModeSelectionContent(maxWidth: 600))),
        ),
      ),
    );
  }
}

class _ModeSelectionContent extends StatelessWidget {
  final double maxWidth;
  const _ModeSelectionContent({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double baseWidth = 420.0;
    double baseHeight = 800.0;
    double widthScale = (maxWidth / baseWidth).clamp(0.7, 1.2);
    double heightScale = (screenHeight / baseHeight).clamp(0.7, 1.2);
    double scale = widthScale < heightScale ? widthScale : heightScale;
    double maxContentWidth = maxWidth * 0.98;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
                minHeight: screenHeight * 0.98,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 48.0 * scale, bottom: 12.0 * scale),
                    child: Image.asset(
                      'assets/loginboard.png',
                      width: (maxContentWidth * 0.85).clamp(160.0, maxContentWidth),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile icon (left)
                      IconButton(
                        icon: CircleAvatar(
                          radius: 22 * scale,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.blue[800], size: 28 * scale),
                        ),
                        tooltip: 'View/Edit Profile',
                        onPressed: () {},
                      ),
                      // Friends and Settings icons (right)
                      Row(
                        children: [
                          IconButton(
                            icon: CircleAvatar(
                              radius: 20 * scale,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.group, color: Colors.blue[800], size: 24 * scale),
                            ),
                            tooltip: 'Friends',
                            onPressed: () {},
                          ),
                          SizedBox(width: 8 * scale),
                          IconButton(
                            icon: CircleAvatar(
                              radius: 20 * scale,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.settings, color: Colors.blue[800], size: 24 * scale),
                            ),
                            tooltip: 'Settings',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  // Game mode options
                  _GameModeButton(
                    icon: Icons.computer,
                    title: 'Solo Challenge',
                    description: 'Play against the computer AI.',
                    onTap: () {},
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  _GameModeButton(
                    icon: Icons.devices,
                    title: 'Local Multiplayer',
                    description: 'Pass the device and play together.',
                    onTap: () {},
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  _GameModeButton(
                    icon: Icons.public,
                    title: 'Global Match',
                    description: 'Compete with players online.',
                    onTap: () {},
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  _GameModeButton(
                    icon: Icons.group_add,
                    title: 'Private Room',
                    description: 'Play with your friends online.',
                    onTap: () {},
                    scale: scale,
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ),
        // Clouds (reuse from login)
        _FloatingCloud(
          initialTop: 8 * scale,
          left: 40 * scale,
          right: null,
          width: 312 * scale,
          height: 182 * scale,
          asset: 'assets/cloud1.svg',
          opacity: 0.85,
          scale: scale,
          phase: 0,
        ),
        _FloatingCloud(
          initialTop: 60 * scale,
          left: null,
          right: 10 * scale,
          width: 240 * scale,
          height: 140 * scale,
          asset: 'assets/cloud2.svg',
          opacity: 0.8,
          scale: scale,
          phase: 1,
        ),
        _FloatingCloud(
          initialTop: 200 * scale,
          left: 40 * scale,
          right: null,
          width: 180 * scale,
          height: 110 * scale,
          asset: 'assets/cloud3.svg',
          opacity: 0.7,
          scale: scale,
          phase: 2,
        ),
        _FloatingCloud(
          initialTop: 200 * scale,
          left: null,
          right: 60 * scale,
          width: 160 * scale,
          height: 100 * scale,
          asset: 'assets/cloud4.svg',
          opacity: 0.75,
          scale: scale,
          phase: 3,
        ),
      ],
    );
  }
}

class _GameModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final double scale;
  const _GameModeButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.scale,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18 * scale, horizontal: 18 * scale),
        margin: EdgeInsets.symmetric(horizontal: 8 * scale),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[900]!.withOpacity(0.08),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 28 * scale,
              child: Icon(icon, color: Colors.blue[800], size: 32 * scale),
            ),
            SizedBox(width: 18 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 18) * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blueGrey[700],
                      fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Copied from login_screen.dart for reuse
class _CheckeredBackground extends StatelessWidget {
  final Widget child;
  const _CheckeredBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckeredPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _CheckeredPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 64;
    final paint1 = Paint()..color = Colors.white.withOpacity(0.07);
    final paint2 = Paint()..color = Colors.white.withOpacity(0.13);
    for (int y = 0; y < size.height / squareSize; y++) {
      for (int x = 0; x < size.width / squareSize; x++) {
        final paint = (x + y) % 2 == 0 ? paint1 : paint2;
        canvas.drawRect(
          Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingCloud extends StatefulWidget {
  final double initialTop;
  final double? left;
  final double? right;
  final double width;
  final double height;
  final String asset;
  final double opacity;
  final double scale;
  final int phase;

  const _FloatingCloud({
    required this.initialTop,
    this.left,
    this.right,
    required this.width,
    required this.height,
    required this.asset,
    required this.opacity,
    required this.scale,
    required this.phase,
    Key? key,
  }) : super(key: key);

  @override
  State<_FloatingCloud> createState() => _FloatingCloudState();
}

class _FloatingCloudState extends State<_FloatingCloud> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value * 2 * math.pi;
        double floatOffset;
        switch (widget.phase) {
          case 0:
            floatOffset = 10.0 * widget.scale * math.sin(t);
            break;
          case 1:
            floatOffset = 10.0 * widget.scale * math.cos(t);
            break;
          case 2:
            floatOffset = 10.0 * widget.scale * math.sin(t + 1);
            break;
          case 3:
            floatOffset = 10.0 * widget.scale * math.cos(t + 1);
            break;
          default:
            floatOffset = 0.0;
        }
        return Positioned(
          top: widget.initialTop * widget.scale + floatOffset,
          left: widget.left,
          right: widget.right,
          child: Opacity(
            opacity: widget.opacity,
            child: Transform(
              transform: Matrix4.identity()..scale(widget.scale, widget.scale),
              alignment: Alignment.center,
              child: widget.asset.endsWith('.svg')
                  ? SvgPicture.asset(
                      widget.asset,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.asset,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
    );
  }
}
