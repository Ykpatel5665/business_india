import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MonoRentRowComponent extends PositionComponent {
  final int count;
  final String value;
  MonoRentRowComponent({required this.count, required this.value, Vector2? position, Vector2? size}) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2(120, 28);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(size.toRect(), paint);

    // Draw icons
    double iconX = 6;
    if (count == 5) {
      _drawIcon(canvas, Icons.apartment, Colors.red, iconX, 4, 22);
      iconX += 26;
    } else {
      for (int i = 0; i < count; i++) {
        _drawIcon(canvas, Icons.house, Colors.green[500]!, iconX, 6, 18);
        iconX += 20;
      }
    }

    // Draw value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.x - textPainter.width - 8, (size.y - textPainter.height) / 2));
  }

  void _drawIcon(Canvas canvas, IconData icon, Color color, double x, double y, double size) {
    final builder = ParagraphBuilder(ParagraphStyle(fontSize: size));
    builder.pushStyle(TextStyle(color: color));
    builder.addText(String.fromCharCode(icon.codePoint));
    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: size));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
