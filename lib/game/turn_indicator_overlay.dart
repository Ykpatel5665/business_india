import 'package:flutter/material.dart';

class TurnIndicatorOverlay extends StatefulWidget {
  final String playerName;
  const TurnIndicatorOverlay({required this.playerName, Key? key}) : super(key: key);

  @override
  State<TurnIndicatorOverlay> createState() => _TurnIndicatorOverlayState();
}

class _TurnIndicatorOverlayState extends State<TurnIndicatorOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _gradientAnimation = ColorTween(
      begin: Colors.blueAccent.withOpacity(0.85),
      end: Colors.deepPurpleAccent.withOpacity(0.85),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedScale(
              scale: 1.1 + 0.04 * _glowAnimation.value,
              curve: Curves.elasticOut,
              duration: const Duration(milliseconds: 400),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Material(
                  color: Colors.transparent,
                  elevation: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _gradientAnimation.value ?? Colors.blueAccent.withOpacity(0.85),
                          Colors.blue.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5 * _glowAnimation.value),
                          blurRadius: 32 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7 + 0.3 * _glowAnimation.value),
                        width: 4 + 2 * _glowAnimation.value,
                      ),
                    ),
                    child: _ShimmerText(text: "It's ${widget.playerName}'s Turn!"),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerText extends StatefulWidget {
  final String text;
  const _ShimmerText({required this.text});
  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.yellowAccent.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
              stops: [
                (_controller.value - 0.2).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.2).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 2)),
              ],
            ),
          ),
        );
      },
    );
  }
}
