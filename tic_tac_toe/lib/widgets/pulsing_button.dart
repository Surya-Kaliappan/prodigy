import 'package:flutter/material.dart';

class PulsingIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const PulsingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<PulsingIconButton> createState() => _PulsingIconButtonState();
}

class _PulsingIconButtonState extends State<PulsingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: _animation.value,
                  spreadRadius: _animation.value / 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Icon(
          widget.icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 32,
        ),
      ),
    );
  }
}
