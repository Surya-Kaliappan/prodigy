import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:tic_tac_toe/models/settings_provider.dart';
import 'package:tic_tac_toe/screens/settings_screen.dart';
import 'package:tic_tac_toe/widgets/game_board.dart';
import 'package:tic_tac_toe/widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool isGameStarted = false;
  bool isSpinning = false;
  bool showArrow = false;
  List<String> board = List.filled(9, '');
  bool isPlayerXTurn = true;
  int scoreX = 0;
  int scoreO = 0;
  bool isGameOver = false;
  List<int> winningLine = [];
  late ConfettiController _confettiController;
  late AnimationController _arrowAnimationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 0.25;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _arrowAnimationController.dispose();
    super.dispose();
  }

  Future<void> _startNewGame() async {
    setState(() {
      board = List.filled(9, '');
      isGameOver = false;
      winningLine = [];
      isSpinning = true;
      showArrow = true;
    });

    _arrowAnimationController.duration = const Duration(milliseconds: 1500);
    _arrowAnimationController.repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _arrowAnimationController.stop();
      setState(() {
        isPlayerXTurn = Random().nextBool();
        isSpinning = false;
        _animateArrowToPlayer(isInitialSpin: true).whenComplete(() {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => showArrow = false);
          });
        });
      });
    });
  }

  Future<void> _animateArrowToPlayer({bool isInitialSpin = false}) async {
    double targetRotation = isPlayerXTurn ? 1.0 : 0.5;
    _arrowAnimationController.duration = isInitialSpin
        ? const Duration(milliseconds: 800)
        : const Duration(milliseconds: 400);
    await _arrowAnimationController.animateTo(
      targetRotation,
      curve: Curves.easeInOut,
    );
  }

  void _handleCellTap(int index) {
    if (board[index].isNotEmpty || isGameOver || isSpinning) return;
    setState(() {
      board[index] = isPlayerXTurn ? 'X' : 'O';
      isPlayerXTurn = !isPlayerXTurn;
      _checkWinner();
    });
  }

  void _checkWinner() {
    const List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var condition in winConditions) {
      String player = board[condition[0]];
      if (player.isNotEmpty &&
          player == board[condition[1]] &&
          player == board[condition[2]]) {
        setState(() {
          if (player == 'X')
            scoreX++;
          else
            scoreO++;
          isGameOver = true;
          winningLine = condition;
          _confettiController.play();
        });
        return;
      }
    }
    if (!board.contains('')) {
      setState(() => isGameOver = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          isGameStarted
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 650) {
                      return _buildWideLayout(settings);
                    } else {
                      return _buildNarrowLayout(settings);
                    }
                  },
                )
              : _buildStartGameButton(),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartGameButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() => isGameStarted = true);
          _startNewGame();
        },
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text("Start Game"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          textStyle: const TextStyle(fontSize: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(SettingsProvider settings) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildAnimatedScoreBoard(),
            const SizedBox(height: 20),
            _buildSmartButton(),
            const Spacer(),
            GameBoard(
              board: board,
              onCellTap: _handleCellTap,
              cellGlowColor: settings.cellGlowColor,
              winningLine: winningLine,
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(SettingsProvider settings) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedScoreBoard(),
              const SizedBox(height: 40),
              _buildSmartButton(),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500 * settings.boardSizeFactor,
                maxHeight: 500 * settings.boardSizeFactor,
              ),
              child: GameBoard(
                board: board,
                onCellTap: _handleCellTap,
                cellGlowColor: settings.cellGlowColor,
                winningLine: winningLine,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedScoreBoard() {
    return AnimatedBuilder(
      animation: _arrowAnimationController,
      builder: (context, child) {
        return ScoreBoard(
          scoreX: scoreX,
          scoreO: scoreO,
          isPlayerXTurn: isPlayerXTurn,
          isGameOver: isGameOver,
          showArrow: showArrow,
          arrowAnimation: _arrowAnimationController,
        );
      },
    );
  }

  Widget _buildSmartButton() {
    // If the arrow is spinning, show an empty space
    if (isSpinning) return const SizedBox(height: 50);

    return Visibility(
      visible: isGameOver,
      // If the game is ongoing, show the Reset button
      replacement: ElevatedButton.icon(
        onPressed: _startNewGame, // Resetting the game now triggers the spin
        icon: const Icon(Icons.refresh),
        label: const Text('Reset Game'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      // If the game is over, show the Play Again button
      child: ElevatedButton.icon(
        onPressed: _startNewGame,
        icon: const Icon(Icons.casino),
        label: const Text('Play Again'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
