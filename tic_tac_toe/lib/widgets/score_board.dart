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
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.center, // This vertically aligns all children
        children: [
          Expanded(
            child: _buildScorePillar(
              context,
              'O',
              scoreO,
              !isPlayerXTurn || isGameOver,
            ),
          ),

          // The arrow is now a direct child of the Row for perfect alignment
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

          Expanded(
            child: _buildScorePillar(
              context,
              'X',
              scoreX,
              isPlayerXTurn || isGameOver,
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
    // We revert to calling the simpler painter constructors
    final painter = player == 'X'
        ? const GlowingXPainter()
        : const GlowingOPainter();
    final symbolSize = MediaQuery.of(context).size.width > 650
        ? 80.0
        : 60.0; // Larger symbols

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: shouldGlow ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: symbolSize,
            height: symbolSize,
            child: CustomPaint(painter: painter),
          ),
        ),
        SizedBox(
          height: 40,
          child: Visibility(
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
        ),
      ],
    );
  }
}
