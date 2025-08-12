import 'package:flutter/material.dart';

class GlowingXPainter extends CustomPainter {
  const GlowingXPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8; // Bolder lines
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final center = size.width / 2;
    // Increased size from 15 to 22 for a larger symbol
    path.moveTo(center - 22, center - 22);
    path.lineTo(center + 22, center + 22);
    path.moveTo(center + 22, center - 22);
    path.lineTo(center - 22, center + 22);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
