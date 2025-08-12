import 'package:flutter/material.dart';
import 'package:tic_tac_toe/widgets/glowing_o_painter.dart';
import 'package:tic_tac_toe/widgets/glowing_x_painter.dart';

class ScoreBoard extends StatelessWidget {
  final int scoreX;
  final int scoreO;
  final bool isPlayerXTurn;
  final bool isGameOver;
  final bool showArrow;
  final Animation<double> arrowAnimation;

  const ScoreBoard({
    super.key,
    required this.scoreX,
    required this.scoreO,
    required this.isPlayerXTurn,
    required this.isGameOver,
    required this.showArrow,
    required this.arrowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Give the scoreboard a fixed height
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: The Player Pillars (stable background)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScorePillar(
                context,
                'O',
                scoreO,
                !isPlayerXTurn || isGameOver,
              ),
              _buildScorePillar(
                context,
                'X',
                scoreX,
                isPlayerXTurn || isGameOver,
              ),
            ],
          ),
          // Layer 2: The Arrow (appears on top without affecting layout)
          AnimatedOpacity(
            opacity: showArrow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: RotationTransition(
              turns: arrowAnimation,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePillar(
    BuildContext context,
    String player,
    int score,
    bool shouldGlow,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = player == 'X' ? Colors.red : Colors.lightBlueAccent;
    final inactiveColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade500;
    final symbolSize = MediaQuery.of(context).size.width > 650 ? 60.0 : 45.0;

    final painter = player == 'X'
        ? GlowingXPainter(color: shouldGlow ? activeColor : inactiveColor)
        : GlowingOPainter(color: shouldGlow ? activeColor : inactiveColor);

    return SizedBox(
      // Use a fixed width to ensure both pillars are the same size
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: symbolSize,
            height: symbolSize,
            child: CustomPaint(painter: painter),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: isGameOver,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(
              score.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
