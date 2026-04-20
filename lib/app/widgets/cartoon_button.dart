import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';

/// A chunky cartoon button with a hard offset shadow that flattens on press.
///
/// This is the most-used widget in the game. Every tap target goes through
/// CartoonButton — never ElevatedButton / TextButton / Material IconButton.
class CartoonButton extends StatefulWidget {
  const CartoonButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.color = GameColors.happyGreen,
    this.foreground = GameColors.white,
    this.size = CartoonButtonSize.medium,
    this.pulse = false,
    this.sparkle = false,
    this.expanded = false,
    this.enabled = true,
  }) : assert(label != null || icon != null,
            'CartoonButton needs at least a label or an icon');

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final CartoonButtonSize size;
  final bool pulse;
  final bool sparkle;
  final bool expanded;
  final bool enabled;

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

enum CartoonButtonSize { small, medium, large, huge }

class _CartoonButtonState extends State<CartoonButton>
    with TickerProviderStateMixin {
  bool _down = false;
  late final AnimationController _pulseCtrl;
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.pulse) _pulseCtrl.repeat(reverse: true);

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.sparkle) _sparkleCtrl.repeat();
  }

  @override
  void didUpdateWidget(covariant CartoonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse != oldWidget.pulse) {
      widget.pulse ? _pulseCtrl.repeat(reverse: true) : _pulseCtrl.stop();
    }
    if (widget.sparkle != oldWidget.sparkle) {
      widget.sparkle ? _sparkleCtrl.repeat() : _sparkleCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onPressed == null) return;
    HapticFeedback.mediumImpact();
    widget.onPressed!();
  }

  ({double fontSize, double padV, double padH, double shadow, double radius})
      get _dims {
    switch (widget.size) {
      case CartoonButtonSize.small:
        return (
          fontSize: 14,
          padV: 8,
          padH: 14,
          shadow: CartoonShape.shadowSmall,
          radius: CartoonShape.radiusSmall,
        );
      case CartoonButtonSize.medium:
        return (
          fontSize: 18,
          padV: 12,
          padH: 20,
          shadow: CartoonShape.shadowMedium,
          radius: CartoonShape.radiusMedium,
        );
      case CartoonButtonSize.large:
        return (
          fontSize: 22,
          padV: 16,
          padH: 28,
          shadow: CartoonShape.shadowMedium + 1,
          radius: CartoonShape.radiusMedium,
        );
      case CartoonButtonSize.huge:
        return (
          fontSize: 28,
          padV: 20,
          padH: 34,
          shadow: CartoonShape.shadowLarge,
          radius: CartoonShape.radiusLarge,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _dims;
    final fill = widget.enabled ? widget.color : Colors.grey.shade400;
    final fg = widget.enabled ? widget.foreground : Colors.grey.shade700;

    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _down ? d.shadow : 0, 0)
          ..scale(_down ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: d.padV, horizontal: d.padH),
        decoration: CartoonShape.cartoonGlossy(
          fill: fill,
          radius: d.radius,
          offset: _down ? 0 : d.shadow,
          borderWidth: CartoonShape.borderMedium,
        ),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: d.fontSize + 4),
              if (widget.label != null) const SizedBox(width: 8),
            ],
            if (widget.label != null)
              Flexible(
                child: Text(
                  widget.label!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GameFonts.buttonLabel(color: fg, size: d.fontSize).copyWith(
                    shadows: [
                      Shadow(
                        color: GameColors.darken(fill, 0.35),
                        offset: const Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    Widget wrapped = child;
    if (widget.pulse) {
      wrapped = AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, inner) {
          final t = Curves.easeInOut.transform(_pulseCtrl.value);
          final scale = 1.0 + 0.04 * t;
          return Transform.scale(scale: scale, child: inner);
        },
        child: wrapped,
      );
    }
    if (widget.sparkle && widget.enabled) {
      wrapped = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _sparkleCtrl,
            builder: (_, child) => CustomPaint(
              painter: _SparklePainter(
                progress: _sparkleCtrl.value,
                color: GameColors.lighten(widget.color, 0.25),
              ),
              child: child,
            ),
            child: wrapped,
          ),
        ],
      );
    }
    return wrapped;
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const _seeds = <Offset>[
    Offset(0.10, 0.25),
    Offset(0.90, 0.40),
    Offset(0.25, 0.85),
    Offset(0.80, 0.10),
    Offset(0.55, 0.95),
    Offset(0.05, 0.60),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var i = 0; i < _seeds.length; i++) {
      final phase = (progress + i / _seeds.length) % 1.0;
      final fade = math.sin(phase * math.pi);
      if (fade <= 0) continue;
      final seed = _seeds[i];
      final center =
          Offset(seed.dx * size.width, seed.dy * size.height);
      final r = 3 + 2 * fade;
      paint.color = color.withValues(alpha: fade);
      _drawStar(canvas, center, r, 4, paint);
    }
  }

  void _drawStar(
      Canvas canvas, Offset c, double r, int points, Paint paint) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = i * math.pi / points - math.pi / 2;
      final radius = i.isEven ? r : r * 0.35;
      final p = c + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) =>
      old.progress != progress || old.color != color;
}
