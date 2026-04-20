import 'package:flutter/material.dart';

import '../../utils/rupee_formatter.dart';
import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';

/// Displays a rupee amount and animates when the value changes. A small
/// floating "+₹500" or "−₹500" popup drifts up on change.
class MoneyCounter extends StatefulWidget {
  const MoneyCounter({
    super.key,
    required this.amount,
    this.size = 18,
    this.color = GameColors.outline,
    this.compact = false,
  });

  final int amount;
  final double size;
  final Color color;
  final bool compact;

  @override
  State<MoneyCounter> createState() => _MoneyCounterState();
}

class _MoneyCounterState extends State<MoneyCounter>
    with SingleTickerProviderStateMixin {
  late int _shown = widget.amount;
  late int _targetAtStart = widget.amount;
  int? _delta;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(_tick);
  }

  void _tick() {
    final t = Curves.easeOut.transform(_ctrl.value);
    setState(() {
      _shown = (_targetAtStart + (widget.amount - _targetAtStart) * t).round();
    });
  }

  @override
  void didUpdateWidget(covariant MoneyCounter old) {
    super.didUpdateWidget(old);
    if (old.amount != widget.amount) {
      _delta = widget.amount - old.amount;
      _targetAtStart = old.amount;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_tick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.compact
        ? RupeeFormatter.compact(_shown)
        : RupeeFormatter.format(_shown);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Text(
          value,
          style: GameFonts.money(color: widget.color, size: widget.size),
        ),
        if (_delta != null && _delta != 0 && _ctrl.isAnimating)
          Positioned(
            top: -20 * _ctrl.value - 4,
            right: -8,
            child: Opacity(
              opacity: (1.0 - _ctrl.value).clamp(0.0, 1.0),
              child: Text(
                '${_delta! >= 0 ? '+' : '−'}${RupeeFormatter.compact(_delta!.abs())}',
                style: GameFonts.fredoka(
                  size: widget.size * 0.72,
                  weight: FontWeight.w900,
                  color: _delta! >= 0
                      ? GameColors.happyGreen
                      : GameColors.happyRed,
                  shadows: [
                    const Shadow(
                      color: GameColors.outline,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
