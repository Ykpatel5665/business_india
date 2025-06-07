import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int dice1;
  final int dice2;
  final bool rolling;
  final VoidCallback onRoll;
  const DiceWidget({
    Key? key,
    required this.dice1,
    required this.dice2,
    required this.rolling,
    required this.onRoll,
  }) : super(key: key);

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayDice1 = 1;
  int _displayDice2 = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addListener(() {
      if (widget.rolling) {
        setState(() {
          _displayDice1 = Random().nextInt(6) + 1;
          _displayDice2 = Random().nextInt(6) + 1;
        });
      }
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _displayDice1 = widget.dice1;
          _displayDice2 = widget.dice2;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rolling && !_controller.isAnimating) {
      _controller.forward(from: 0);
    }
    if (!widget.rolling && !_controller.isAnimating) {
      setState(() {
        _displayDice1 = widget.dice1;
        _displayDice2 = widget.dice2;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDie(int value) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDie(_displayDice1),
            const SizedBox(width: 12),
            _buildDie(_displayDice2),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: widget.rolling ? null : widget.onRoll,
          child: const Text('Roll Dice'),
        ),
      ],
    );
  }
}
