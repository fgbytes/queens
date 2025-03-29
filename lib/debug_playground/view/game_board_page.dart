import 'package:flutter/material.dart';
import 'package:queens/debug_playground/models/game_board_model.dart';
import 'package:queens/debug_playground/widgets/game_board_widget.dart';

class GameBoardPage extends StatefulWidget {
  const GameBoardPage({super.key});

  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  late GameBoard gameBoard;
  final int _boardSize = 10; // Default board size

  @override
  void initState() {
    super.initState();
    // Create a sample game board
    gameBoard = GameBoard.sample(_boardSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queens Game Board'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tap to cycle: Empty → Dot → Queen',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Center the game board
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square aspect ratio
                    child: GameBoardWidget(gameBoard: gameBoard),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Instructions
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to Play:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• Tap a cell once to place a dot'),
                      Text('• Tap again to place a queen'),
                      Text('• Tap a queen to remove it'),
                      SizedBox(height: 8),
                      Text(
                        'Game rules would be explained here in a real version.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetBoard,
        tooltip: 'Reset Board',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _resetBoard() {
    setState(() {
      gameBoard = GameBoard.sample(_boardSize);
    });
  }
}
