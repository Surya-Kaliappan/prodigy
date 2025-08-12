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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final arrowColor = isDarkMode ? Colors.white : Colors.black;

    return SizedBox(
      height: 120, // Give the scoreboard a fixed height
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScorePillar(
                context,
                'O',
                scoreO,
                !isPlayerXTurn || isGameOver,
              ),
              const SizedBox(width: 40), // Placeholder for arrow space
              _buildScorePillar(
                context,
                'X',
                scoreX,
                isPlayerXTurn || isGameOver,
              ),
            ],
          ),
          Visibility(
            visible: showArrow,
            child: RotationTransition(
              turns: arrowAnimation,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
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
    bool isActive,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor = player == 'X' ? Colors.red : Colors.lightBlueAccent;
    final inactiveColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade400;
    final symbolSize = MediaQuery.of(context).size.width > 650 ? 60.0 : 45.0;

    final painter = player == 'X'
        ? GlowingXPainter(color: isActive ? activeColor : inactiveColor)
        : GlowingOPainter(color: isActive ? activeColor : inactiveColor);

    return Column(
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
