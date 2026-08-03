import 'package:flutter/material.dart';

class NotebookLinesPainter extends CustomPainter {
  final double lineHeight;
  final Color lineColor;

  const NotebookLinesPainter({
    required this.lineHeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    double y = lineHeight;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant NotebookLinesPainter old) {
    return old.lineHeight != lineHeight || old.lineColor != lineColor;
  }
}