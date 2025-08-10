import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// Custom Painter for the OVAL track animation
class TrackPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  TrackPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final paintRect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      paintRect,
      Radius.circular(size.height / 2),
    );

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final foregroundPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0);

    canvas.drawRRect(rrect, backgroundPaint);

    Path path = Path()..addRRect(rrect);
    PathMetric pathMetric = path.computeMetrics().first;
    Path extractPath = pathMetric.extractPath(
      0.0,
      pathMetric.length * progress,
    );

    canvas.drawPath(extractPath, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant TrackPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Pulsing Scroll Arrow Indicator
class ScrollIndicator extends StatefulWidget {
  final IconData icon;
  final Color color;
  const ScrollIndicator({super.key, required this.icon, required this.color});

  @override
  State<ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.1, end: 0.7).animate(_controller),
      child: Icon(widget.icon, color: widget.color, size: 28),
    );
  }
}

// Animated Particle Overlay
class MovingParticles extends StatefulWidget {
  final Color baseColor;
  const MovingParticles({super.key, required this.baseColor});

  @override
  State<MovingParticles> createState() => _MovingParticlesState();
}

class _MovingParticlesState extends State<MovingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> particles = [];
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < 150; i++) {
        particles.add(_Particle(random, MediaQuery.of(context).size));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var particle in particles) {
          particle.update(MediaQuery.of(context).size);
        }
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: particles,
            baseColor: widget.baseColor,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color baseColor;

  _ParticlePainter({required this.particles, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = baseColor.withOpacity(particle.opacity);
      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  late Offset position;
  late Offset velocity;
  late double radius;
  late double opacity;
  final math.Random random;

  _Particle(this.random, Size bounds) {
    reset(bounds);
  }

  void reset(Size bounds) {
    int edge = random.nextInt(4);
    if (edge == 0) {
      position = Offset(random.nextDouble() * bounds.width, -5);
    } else if (edge == 1) {
      position = Offset(bounds.width + 5, random.nextDouble() * bounds.height);
    } else if (edge == 2) {
      position = Offset(random.nextDouble() * bounds.width, bounds.height + 5);
    } else {
      position = Offset(-5, random.nextDouble() * bounds.height);
    }

    velocity = Offset(
      (random.nextDouble() - 0.5) * 1.2,
      (random.nextDouble() - 0.5) * 1.2,
    );
    radius = random.nextDouble() * 2.0 + 1.0;
    opacity = random.nextDouble() * 0.15 + 0.05;
  }

  void update(Size bounds) {
    position += velocity;
    if (position.dx < -10 ||
        position.dx > bounds.width + 10 ||
        position.dy < -10 ||
        position.dy > bounds.height + 10) {
      reset(bounds);
    }
  }
}
