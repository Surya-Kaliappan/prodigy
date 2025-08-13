import 'package:flutter/material.dart';

class GlowingXPainter extends CustomPainter {
  const GlowingXPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final center = size.width / 2;
    // Adjusted size to match the new 'O' size
    final offset = size.width / 2.5;
    path.moveTo(center - offset, center - offset);
    path.lineTo(center + offset, center + offset);
    path.moveTo(center + offset, center - offset);
    path.lineTo(center - offset, center + offset);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
