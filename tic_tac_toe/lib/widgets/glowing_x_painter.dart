import 'package:flutter/material.dart';

class GlowingXPainter extends CustomPainter {
  final Color color;
  const GlowingXPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    final glowPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final path = Path();
    final center = size.width / 2;
    path.moveTo(center - 15, center - 15);
    path.lineTo(center + 15, center + 15);
    path.moveTo(center + 15, center - 15);
    path.lineTo(center - 15, center + 20);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
