import 'package:flutter/material.dart';
import 'package:queens/debug_playground/models/game_board_model.dart';
import 'package:queens/debug_playground/widgets/game_board_widget.dart';

class ResizableGameBoardPage extends StatefulWidget {
  const ResizableGameBoardPage({super.key});

  @override
  State<ResizableGameBoardPage> createState() => _ResizableGameBoardPageState();
}

class _ResizableGameBoardPageState extends State<ResizableGameBoardPage> {
  late GameBoard _gameBoard;
  int _boardSize = 10; // Default board size

  @override
  void initState() {
    super.initState();
    _gameBoard = GameBoard.sample(_boardSize);
  }

  void _decreaseBoardSize() {
    if (_boardSize > 6) {
      // Minimum size limit
      setState(() {
        _boardSize--;
        _gameBoard = GameBoard.sample(_boardSize);
      });
    }
  }

  void _increaseBoardSize() {
    if (_boardSize < 12) {
      // Maximum size limit
      setState(() {
        _boardSize++;
        _gameBoard = GameBoard.sample(_boardSize);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Resizable Game Board'),
        backgroundColor: Colors.teal[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Board Size:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _decreaseBoardSize,
                  tooltip: 'Decrease board size',
                ),
                Text(
                  '$_boardSize × $_boardSize',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _increaseBoardSize,
                  tooltip: 'Increase board size',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 500,
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GameBoardWidget(
                    gameBoard: _gameBoard,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gameBoard = GameBoard.sample(_boardSize);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Reset Board',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
