import 'package:flutter/material.dart';
import 'package:queens/game/models/game_board_model.dart';
import 'package:queens/game/widgets/game_board_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameBoard _gameBoard;
  int _boardSize = 10;
  // Counter to trigger widget rebuild/re-animation via ValueKey
  int _animationRun = 0;
  // Remove _animateBoard flag
  // bool _animateBoard = true;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    // No need to manage _animateBoard flag after build here
  }

  // Helper to initialize or reset board state data
  void _initializeBoard() {
    _gameBoard = GameBoard.sample(_boardSize);
    // Animation trigger is handled by key change now
  }

  void _decreaseBoardSize() {
    if (_boardSize > 6) {
      setState(() {
        _boardSize--;
        _initializeBoard();
        _animationRun++; // Trigger animation on size change
      });
    }
  }

  void _increaseBoardSize() {
    if (_boardSize < 12) {
      setState(() {
        _boardSize++;
        _initializeBoard();
        _animationRun++; // Trigger animation on size change
      });
    }
  }

  // Resets the board data AND triggers animation
  void _resetBoardAndAnimate() {
    setState(() {
      _initializeBoard();
      _animationRun++;
    });
  }

  // Only triggers animation replay on current board state
  void _replayAnimation() {
    setState(() {
      _animationRun++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queens Game'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Size Controls (unchanged)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Board Size:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: theme.colorScheme.primary),
                    onPressed: _decreaseBoardSize,
                    tooltip: 'Decrease board size',
                  ),
                  Text(
                    '$_boardSize × $_boardSize',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary),
                    onPressed: _increaseBoardSize,
                    tooltip: 'Increase board size',
                  ),
                ],
              ),
            ),

            // Board Area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      maxHeight: 600,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GameBoardWidget(
                        // Use ValueKey to force state rebuild on change
                        key: ValueKey(_animationRun),
                        gameBoard: _gameBoard,
                        // Always pass animate: true
                        animate: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Controls Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      // Reset button now resets data AND animates
                      onPressed: _resetBoardAndAnimate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      // Animate button now only replays animation
                      onPressed: _replayAnimation,
                      icon: const Icon(Icons.replay_circle_filled),
                      label: const Text('Animate'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
