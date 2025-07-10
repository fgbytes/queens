import 'package:flutter/material.dart';

/// Represents a cell's state in the game
enum CellState {
  empty,
  dot,
  queen,
}

/// Represents a cell on the board
class Cell {
  Cell({
    required this.row,
    required this.col,
    required this.kingdomId,
    this.state = CellState.empty,
  });

  final int row;
  final int col;
  final int kingdomId;
  CellState state;

  /// Cycles through the cell states: empty -> dot -> queen -> empty
  void cycleState() {
    switch (state) {
      case CellState.empty:
        state = CellState.dot;
      case CellState.dot:
        state = CellState.queen;
      case CellState.queen:
        state = CellState.empty;
    }
  }
}

/// Represents a kingdom (a group of cells with the same color)
class Kingdom {
  Kingdom({
    required this.id,
    required this.color,
    required this.backgroundColor,
    required this.cells,
  });

  final int id;
  final Color color;
  final Color backgroundColor;
  final List<Cell> cells;
}

/// Represents the game board
class GameBoard {
  GameBoard({
    required this.size,
    required this.kingdoms,
  });

  /// Create a game board with a more realistic layout of kingdoms
  factory GameBoard.sample(int size) {
    // Define kingdom colors with exact hex codes provided
    final colors = [
      const Color(0xFFB8EFFF), // Blue - cells
      const Color(0xFFFFEDC7), // Yellow - cells
      const Color(0xFFE9F7D8), // Green - cells
      const Color(0xFFEFEAFD), // Purple - cells
      const Color(0xFFFFE6E6), // Light pink - cells (keeping as fallback)
    ];

    // Background colors for each kingdom (shown in gaps)
    final backgroundColors = [
      const Color(0xFF5ABDD9), // Blue - background
      const Color(0xFFE0BD6A), // Yellow - background
      const Color(0xFF5ABDD9), // Green - background
      const Color(0xFF917FC9), // Purple - background
      const Color(0xFFFFCCCC), // Light pink - background (fallback)
    ];

    // Create a dynamic kingdom layout based on the given size
    final kingdomLayout = _generateKingdomLayout(size);

    // Create a map to track which cells belong to which kingdoms
    final kingdomCells = <int, List<Cell>>{};

    // Create cells based on the kingdom layout
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final kingdomId = kingdomLayout[row][col];

        // Create the cell and add it to the appropriate kingdom
        final cell = Cell(row: row, col: col, kingdomId: kingdomId);
        kingdomCells.putIfAbsent(kingdomId, () => []).add(cell);
      }
    }

    // Create the kingdoms with their cells and custom colors
    final kingdoms = <Kingdom>[];
    kingdomCells.forEach((id, cells) {
      kingdoms.add(
        Kingdom(
          id: id,
          color: colors[id % colors.length],
          backgroundColor: backgroundColors[id % backgroundColors.length],
          cells: cells,
        ),
      );
    });

    // Add some initial queens/dots for testing
    _setInitialPieces(kingdoms, size);

    return GameBoard(size: size, kingdoms: kingdoms);
  }

  final int size;
  final List<Kingdom> kingdoms;

  /// Generate a kingdom layout based on board size
  static List<List<int>> _generateKingdomLayout(int size) {
    // Create a more visually appealing and connected kingdom layout
    final layout = List.generate(
      size,
      (row) => List.filled(size, 0), // Initialize with zeros
    );

    // Define kingdom boundaries more carefully to ensure each is connected
    // For clarity, we'll use a more explicit approach

    // Define kingdom 0 (Blue, top-right)
    final k0StartCol = size ~/ 2;
    final k0EndRow = size ~/ 2;
    for (var r = 0; r < k0EndRow; r++) {
      for (var c = k0StartCol; c < size; c++) {
        layout[r][c] = 0;
      }
    }

    // Add bottom section for kingdom 0
    for (var r = k0EndRow; r < size * 2 ~/ 3; r++) {
      for (var c = size * 2 ~/ 3; c < size; c++) {
        layout[r][c] = 0;
      }
    }

    // Define kingdom 1 (Yellow, bottom-left)
    final k1StartRow = size * 2 ~/ 3;
    final k1EndCol = size ~/ 2;
    for (var r = k1StartRow; r < size; r++) {
      for (var c = 0; c < k1EndCol; c++) {
        layout[r][c] = 1;
      }
    }

    // Define kingdom 2 (Green, top-left)
    final k2EndRow = size ~/ 3;
    final k2EndCol = size * 2 ~/ 3;
    for (var r = 0; r < k2EndRow; r++) {
      for (var c = 0; c < k2EndCol; c++) {
        layout[r][c] = 2;
      }
    }

    // Define kingdom 3 (Purple, middle-left)
    final k3StartRow = size ~/ 3;
    final k3EndRow = size * 2 ~/ 3;
    final k3EndCol = size ~/ 2;
    for (var r = k3StartRow; r < k3EndRow; r++) {
      for (var c = 0; c < k3EndCol; c++) {
        layout[r][c] = 3;
      }
    }

    // Define kingdom 4 (Pink, bottom-right)
    final k4StartRow = k3EndRow;
    final k4StartCol = k1EndCol;
    for (var r = k4StartRow; r < size; r++) {
      for (var c = k4StartCol; c < size; c++) {
        layout[r][c] = 4;
      }
    }

    // Fill any remaining cells (shouldn't be any, but just in case)
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (layout[r][c] == 0 && (r >= k0EndRow || c < k0StartCol)) {
          // This is a cell that should be assigned to another kingdom
          // Assign it based on position
          if (r < size ~/ 2) {
            layout[r][c] = 3; // Assign to purple
          } else {
            layout[r][c] = 4; // Assign to pink
          }
        }
      }
    }

    return layout;
  }

  /// Get a cell at specific row and column
  Cell? getCell(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return null;
    }

    for (final kingdom in kingdoms) {
      for (final cell in kingdom.cells) {
        if (cell.row == row && cell.col == col) {
          return cell;
        }
      }
    }
    return null;
  }

  /// Reset all cells to empty state and add a random distribution of pieces
  void resetBoard() {
    // Clear all existing pieces
    for (final kingdom in kingdoms) {
      for (final cell in kingdom.cells) {
        cell.state = CellState.empty;
      }
    }

    // Add new random pieces
    _setInitialPieces(kingdoms, size);
  }

  /// Set initial queens and dots on the board
  static void _setInitialPieces(List<Kingdom> kingdoms, int size) {
    // Scale number of queens based on board size 
    //(approximately 12 for a 10x10 board)
    final numQueens = (size * size * 0.12).round();
    final queensPositions = <List<int>>[];

    // Distribute queens somewhat evenly
    var count = 0;
    while (count < numQueens) {
      final row = count * size ~/ numQueens;
      final col = (count % 3) * (size ~/ 3);

      // Avoid duplicates
      if (!queensPositions.any((pos) => pos[0] == row && pos[1] == col)) {
        queensPositions.add([row, col]);
        count++;
      } else {
        // Try a slightly different position
        queensPositions.add([
          (row + 1) % size,
          (col + 2) % size,
        ]);
        count++;
      }
    }

    // Place queens
    for (final pos in queensPositions) {
      final row = pos[0];
      final col = pos[1];

      for (final kingdom in kingdoms) {
        for (final cell in kingdom.cells) {
          if (cell.row == row && cell.col == col) {
            cell.state = CellState.queen;
            break;
          }
        }
      }
    }
  }
}
