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
    // This simple Row is now the entire layout.
    // CrossAxisAlignment.center is the key to perfect vertical alignment.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Player O Pillar
        Expanded(
          child: _buildScorePillar(
            context,
            'O',
            scoreO,
            !isPlayerXTurn || isGameOver,
          ),
        ),

        // The Arrow
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

        // Player X Pillar
        Expanded(
          child: _buildScorePillar(
            context,
            'X',
            scoreX,
            isPlayerXTurn || isGameOver,
          ),
        ),
      ],
    );
  }

  Widget _buildScorePillar(
    BuildContext context,
    String player,
    int score,
    bool shouldGlow,
  ) {
    final painter = player == 'X'
        ? const GlowingXPainter()
        : const GlowingOPainter();
    final symbolSize = MediaQuery.of(context).size.width > 650 ? 80.0 : 60.0;

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
        const SizedBox(height: 10),
        // Using AnimatedOpacity instead of Visibility is better for layout stability
        AnimatedOpacity(
          opacity: isGameOver ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            score.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
