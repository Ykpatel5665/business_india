import 'package:flutter/material.dart';
import 'package:business_india/screens/widgets/game_button/liquid_ripple.dart';
import 'dart:math' as Math;

/// AnimatedGameButton: A reusable animated button widget with a game-like feel.
/// Highly modular, game-styled, and plug-and-play for Monopoly UI.
class AnimatedGameButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double scale;
  final Color color;
  final Color textColor;
  final bool enabled;
  final IconData? icon;

  const AnimatedGameButton({
    super.key,
    required this.label,
    this.onPressed,
    this.scale = 1.0,
    this.color = const Color(0xFFFFE066), // Cartoon yellow
    this.textColor = const Color(0xFF222222),
    this.enabled = true,
    this.icon,
  });

  @override
  State<AnimatedGameButton> createState() => _AnimatedGameButtonState();
}

class _AnimatedGameButtonState extends State<AnimatedGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.stop();
      _controller.forward();
      // Add a quick liquid ripple effect
      setState(() {
        _showRipple = true;
        _rippleKey = UniqueKey();
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.stop();
      _controller.reverse();
      setState(() {
        _showRipple = false;
      });
    }
  }

  void _onTapCancel() {
    if (widget.enabled) {
      _controller.stop();
      _controller.reverse();
      setState(() {
        _showRipple = false;
      });
    }
  }

  bool _showRipple = false;
  Key? _rippleKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.08);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Liquid/Glossy background effect
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 18 * widget.scale,
                horizontal: 36 * widget.scale,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.95),
                    Colors.white.withOpacity(0.65),
                    widget.color.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(28 * widget.scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 22 * widget.scale,
                    offset: Offset(0, 10 * widget.scale),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 0,
                    spreadRadius: 2 * widget.scale,
                    offset: Offset(0, -2 * widget.scale),
                  ),
                ],
                border: Border.all(
                  color: Colors.orangeAccent.withOpacity(0.95),
                  width: 5.0 * widget.scale,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Liquid shine highlight
                  Positioned(
                    top: 8 * widget.scale,
                    left: 18 * widget.scale,
                    child: Container(
                      width: 48 * widget.scale,
                      height: 16 * widget.scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.55),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12 * widget.scale),
                      ),
                    ),
                  ),
                  // Bubble effect
                  Positioned(
                    bottom: 10 * widget.scale,
                    right: 24 * widget.scale,
                    child: Container(
                      width: 16 * widget.scale,
                      height: 16 * widget.scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18 * widget.scale,
                    left: 32 * widget.scale,
                    child: Container(
                      width: 10 * widget.scale,
                      height: 10 * widget.scale,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Button content
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor, size: 26 * widget.scale, shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 2 * widget.scale,
                            offset: Offset(1, 2 * widget.scale),
                          ),
                        ]),
                        SizedBox(width: 12 * widget.scale),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 22 * widget.scale,
                          letterSpacing: 1.2 * widget.scale,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 0,
                              offset: Offset(0, 2 * widget.scale),
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 2 * widget.scale,
                              offset: Offset(1, 2 * widget.scale),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showRipple)
              LiquidRipple(
                color: widget.color,
                show: _showRipple,
                rippleKey: _rippleKey,
              ),
          ],
        ),
      ),
    );
  }
}
