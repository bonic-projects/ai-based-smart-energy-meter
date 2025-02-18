import 'package:flutter/material.dart';
import 'dart:math' show pi;

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color color;

  GaugePainter({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;

    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius / 2),
      -pi * 0.8,
      pi * 1.6,
      false,
      bgPaint,
    );

    // Draw value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final valueAngle = (value / maxValue).clamp(0.0, 1.0) * pi * 1.6;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius / 2),
      -pi * 0.8,
      valueAngle,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) =>
      value != oldDelegate.value ||
      maxValue != oldDelegate.maxValue ||
      color != oldDelegate.color;
}
