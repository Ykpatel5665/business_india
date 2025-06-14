import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// CloudWidget: Animated SVG cloud for playful Monopoly backgrounds.
/// Highly reusable and responsive for any game screen.
class CloudWidget extends StatefulWidget {
  final String assetName;
  final double width;
  final double height;
  final double opacity;
  final double? leftBegin;
  final double? leftEnd;
  final double? rightBegin;
  final double? rightEnd;
  final double? top;
  final double? bottom;
  final int durationSeconds;
  final double speed;

  const CloudWidget({
    super.key,
    required this.assetName,
    required this.width,
    required this.height,
    this.opacity = 1.0,
    this.leftBegin,
    this.leftEnd,
    this.rightBegin,
    this.rightEnd,
    this.top,
    this.bottom,
    this.durationSeconds = 20,
    this.speed = 1.0,
  });

  @override
  State<CloudWidget> createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: (widget.durationSeconds / widget.speed).round(),
      ),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Make cloud size responsive to screen size
    final responsiveWidth = widget.width * (screenWidth / 400).clamp(0.7, 2.0);
    final responsiveHeight = widget.height * (screenHeight / 800).clamp(0.7, 2.0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double? left, right, top, bottom;
        if (widget.leftBegin != null && widget.leftEnd != null) {
          left = screenWidth *
              (widget.leftBegin! + (widget.leftEnd! - widget.leftBegin!) * _animation.value);
        }
        if (widget.rightBegin != null && widget.rightEnd != null) {
          right = screenWidth *
              (widget.rightBegin! + (widget.rightEnd! - widget.rightBegin!) * _animation.value);
        }
        top = widget.top;
        bottom = widget.bottom;
        return Positioned(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
          child: Opacity(
            opacity: widget.opacity,
            child: SvgPicture.asset(
              widget.assetName,
              width: responsiveWidth,
              height: responsiveHeight,
            ),
          ),
        );
      },
    );
  }
}
