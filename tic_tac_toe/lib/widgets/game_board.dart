import 'package:flutter/material.dart';
import 'package:tic_tac_toe/widgets/game_cell.dart';

class GameBoard extends StatelessWidget {
  final List<String> board;
  final Function(int) onCellTap;
  final Color cellGlowColor;
  final List<int> winningLine; // Add this line

  const GameBoard({
    super.key,
    required this.board,
    required this.onCellTap,
    required this.cellGlowColor,
    required this.winningLine, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    // ... LayoutBuilder remains the same
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth > constraints.maxHeight
            ? constraints.maxHeight
            : constraints.maxWidth;
        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: GridView.builder(
            itemCount: 9,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GameCell(
                symbol: board[index],
                onTap: () => onCellTap(index),
                glowColor: cellGlowColor,
                isWinningCell: winningLine.contains(
                  index,
                ), // Pass down winning status
              );
            },
          ),
        );
      },
    );
  }
}
