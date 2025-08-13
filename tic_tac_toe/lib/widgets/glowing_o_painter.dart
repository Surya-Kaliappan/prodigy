import 'package:flutter/material.dart';

class GlowingOPainter extends CustomPainter {
  const GlowingOPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final glowPaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final center = Offset(size.width / 2, size.height / 2);
    // Adjusted radius calculation to make it larger
    final radius = size.width / 2 * 0.8;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
