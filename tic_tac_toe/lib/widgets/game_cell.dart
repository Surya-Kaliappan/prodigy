import 'package:flutter/material.dart';
import 'package:tic_tac_toe/widgets/glowing_o_painter.dart';
import 'package:tic_tac_toe/widgets/glowing_x_painter.dart';

class GameCell extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;
  final Color glowColor;
  final bool isWinningCell;

  const GameCell({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.glowColor,
    required this.isWinningCell,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cellColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // Winning cell glow
            if (isWinningCell)
              BoxShadow(
                color: symbol == 'X' ? Colors.red : Colors.lightBlueAccent,
                blurRadius: 20.0,
                spreadRadius: 5.0,
              )
            // Empty cell glow
            else if (symbol.isEmpty)
              BoxShadow(color: glowColor, blurRadius: 4.0),
          ],
        ),
        child: Center(child: _buildSymbol()),
      ),
    );
  }

  Widget _buildSymbol() {
    if (symbol == 'X') {
      // FIX: Provide the required 'color' parameter
      return CustomPaint(
        painter: GlowingXPainter(color: Colors.red),
        size: const Size(60, 60),
      );
    } else if (symbol == 'O') {
      // FIX: Provide the required 'color' parameter
      return CustomPaint(
        painter: GlowingOPainter(color: Colors.lightBlueAccent),
        size: const Size(60, 60),
      );
    }
    return Container();
  }
}
