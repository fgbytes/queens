import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:queens/debug_playground/models/game_board_model.dart';
import 'package:queens/debug_playground/widgets/game_cell.dart';

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({
    super.key,
    required this.gameBoard,
  });

  final GameBoard gameBoard;

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return CustomPaint(
          size: Size(size, size),
          painter: GameBoardPainter(
            gameBoard: widget.gameBoard,
            boardSize: size,
          ),
          child: GestureDetector(
            onTapDown: (details) => _handleTap(details, size),
            child: Container(
              width: size,
              height: size,
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapDownDetails details, double boardSize) {
    final cellSize = boardSize / widget.gameBoard.size;
    final col = (details.localPosition.dx / cellSize).floor();
    final row = (details.localPosition.dy / cellSize).floor();

    if (row >= 0 &&
        row < widget.gameBoard.size &&
        col >= 0 &&
        col < widget.gameBoard.size) {
      setState(() {
        final cell = widget.gameBoard.getCell(row, col);
        if (cell != null) {
          cell.cycleState();
        }
      });
    }
  }
}

// Define a simple record for border segments
typedef BorderSegment = ({Offset start, Offset end});

class GameBoardPainter extends CustomPainter {
  GameBoardPainter({
    required this.gameBoard,
    required this.boardSize,
  });

  final GameBoard gameBoard;
  final double boardSize;

  // Constants for visual appearance
  static const Color outerBorderColor = Color(0xFF70392A);
  static const double outerBorderWidth = 3.0;
  static const double kingdomBorderWidth = 2.0;
  static final Color kingdomBorderColor = Colors.brown[600]!;
  static const double _epsilon = 0.1; // Tolerance for comparing offsets

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = boardSize / gameBoard.size;

    // Save the canvas state before applying clipping
    canvas.save();

    // Define the clip region with same rounded corners as the outer border
    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, boardSize, boardSize),
        const Radius.circular(10),
      ));

    // Apply the clip to ensure all content stays within the rounded border
    canvas.clipPath(clipPath);

    // --- Drawing Order (modified to respect clipping) ---
    // 1. Board Background
    _drawBoardBackground(canvas);

    // 2. Kingdom Backgrounds
    _drawKingdomBackgroundFills(canvas, cellSize);

    // 3. Individual Cells
    _drawCells(canvas, cellSize);

    // 4. Kingdom Borders
    _drawTrulyRoundedKingdomBorders(canvas, cellSize);

    // 5. Cell Contents
    _drawCellContents(canvas, cellSize);

    // Restore canvas state (remove clipping) before drawing the outer border
    canvas.restore();

    // 6. Outer Border - drawn AFTER restoring canvas to ensure it's not clipped
    _drawOuterBorder(canvas);
  }

  // --- Drawing Methods ---

  void _drawBoardBackground(Canvas canvas) {
    final boardBackgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Fill the entire clipped area
    canvas.drawRect(
      Rect.fromLTWH(0, 0, boardSize, boardSize),
      boardBackgroundPaint,
    );
  }

  void _drawKingdomBackgroundFills(Canvas canvas, double cellSize) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    for (final kingdom in gameBoard.kingdoms) {
      fillPaint.color =
          kingdom.backgroundColor; // Use the specified background color
      final Path path = Path();
      for (final cell in kingdom.cells) {
        path.addRect(Rect.fromLTWH(
          cell.col * cellSize,
          cell.row * cellSize,
          cellSize,
          cellSize,
        ));
      }
      canvas.drawPath(path, fillPaint);
    }
  }

  void _drawCells(Canvas canvas, double cellSize) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    for (final kingdom in gameBoard.kingdoms) {
      fillPaint.color = kingdom.color; // Use the specified cell color
      for (final cell in kingdom.cells) {
        final cellRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cell.col * cellSize + 0.5,
            cell.row * cellSize + 0.5,
            cellSize - 1.0,
            cellSize - 1.0,
          ),
          const Radius.circular(4), // Rounded corners for each cell
        );
        canvas.drawRRect(cellRect, fillPaint);
      }
    }
  }

  void _drawTrulyRoundedKingdomBorders(Canvas canvas, double cellSize) {
    final borderPaint = Paint()
      ..color = kingdomBorderColor
      ..strokeWidth = kingdomBorderWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Corner radius - adjust for desired roundness
    final cornerRadius = cellSize * 0.25;

    for (final kingdom in gameBoard.kingdoms) {
      // Get all separate regions of this kingdom
      final List<List<Offset>> regionVertices =
          _getKingdomRegionVertices(kingdom, cellSize);

      // Draw each region separately
      for (final vertices in regionVertices) {
        if (vertices.length < 3) continue; // Need at least 3 points for corners

        // Create a new path with rounded corners
        final Path roundedPath = Path();
        final int n = vertices.length;

        // Process each vertex
        for (int i = 0; i < n; i++) {
          final prevIndex = (i > 0) ? i - 1 : n - 1;
          final currIndex = i;
          final nextIndex = (i < n - 1) ? i + 1 : 0;

          final prevVertex = vertices[prevIndex];
          final currVertex = vertices[currIndex];
          final nextVertex = vertices[nextIndex];

          // Calculate vectors
          final incomingVector = Offset(
            currVertex.dx - prevVertex.dx,
            currVertex.dy - prevVertex.dy,
          );
          final outgoingVector = Offset(
            nextVertex.dx - currVertex.dx,
            nextVertex.dy - currVertex.dy,
          );

          // Check if this is a straight line (no actual corner)
          final incomingLength =
              sqrt(pow(incomingVector.dx, 2) + pow(incomingVector.dy, 2));
          final outgoingLength =
              sqrt(pow(outgoingVector.dx, 2) + pow(outgoingVector.dy, 2));

          // Normalize vectors
          final incomingNormalized = Offset(
            incomingVector.dx / incomingLength,
            incomingVector.dy / incomingLength,
          );
          final outgoingNormalized = Offset(
            outgoingVector.dx / outgoingLength,
            outgoingVector.dy / outgoingLength,
          );

          // Dot product to check angle
          final dotProduct = incomingNormalized.dx * outgoingNormalized.dx +
              incomingNormalized.dy * outgoingNormalized.dy;

          // Threshold for straight-line detection (cos(10°) ≈ 0.985)
          if (dotProduct > 0.985) {
            // This is approximately a straight line
            if (i == 0) {
              roundedPath.moveTo(currVertex.dx, currVertex.dy);
            } else {
              roundedPath.lineTo(currVertex.dx, currVertex.dy);
            }
            continue;
          }

          // Distance from corner for control points
          final distance =
              min(cornerRadius, min(incomingLength / 2, outgoingLength / 2));

          // Points before and after corner for the curve
          final beforeCorner = Offset(
            currVertex.dx - incomingNormalized.dx * distance,
            currVertex.dy - incomingNormalized.dy * distance,
          );

          final afterCorner = Offset(
            currVertex.dx + outgoingNormalized.dx * distance,
            currVertex.dy + outgoingNormalized.dy * distance,
          );

          // Start the path or continue from previous point
          if (i == 0) {
            roundedPath.moveTo(beforeCorner.dx, beforeCorner.dy);
          } else {
            roundedPath.lineTo(beforeCorner.dx, beforeCorner.dy);
          }

          // Add the rounded corner using a quadratic Bezier curve
          roundedPath.quadraticBezierTo(
            currVertex.dx,
            currVertex.dy, // Control point at the original corner
            afterCorner.dx, afterCorner.dy, // End point after the corner
          );
        }

        // Close the path
        roundedPath.close();

        // Draw the rounded path
        canvas.drawPath(roundedPath, borderPaint);
      }
    }
  }

  // Helper to identify separate regions in a kingdom and get vertices for each
  List<List<Offset>> _getKingdomRegionVertices(
      Kingdom kingdom, double cellSize) {
    // First, identify connected regions within the kingdom
    final regions = _identifyConnectedRegions(kingdom);

    // Then, get the outline vertices for each region
    final List<List<Offset>> allRegionVertices = [];

    for (final region in regions) {
      // Create a sub-kingdom with just this region's cells
      final regionKingdom = Kingdom(
        id: kingdom.id,
        color: kingdom.color,
        backgroundColor: kingdom.backgroundColor,
        cells: region,
      );

      // Get the ordered vertices for this region only
      final vertices = _getOrderedKingdomVertices(regionKingdom, cellSize);
      if (vertices.isNotEmpty) {
        allRegionVertices.add(vertices);
      }
    }

    return allRegionVertices;
  }

  // Helper to identify separate, connected regions within a kingdom
  List<List<Cell>> _identifyConnectedRegions(Kingdom kingdom) {
    final List<List<Cell>> regions = [];
    final Set<Cell> unprocessedCells = Set.from(kingdom.cells);

    while (unprocessedCells.isNotEmpty) {
      // Start a new region with the first unprocessed cell
      final Cell startCell = unprocessedCells.first;
      final List<Cell> currentRegion = [];
      final Set<Cell> cellsToProcess = {startCell};

      // Flood fill to find all cells connected to this region
      while (cellsToProcess.isNotEmpty) {
        final Cell cell = cellsToProcess.first;
        cellsToProcess.remove(cell);

        if (unprocessedCells.contains(cell)) {
          currentRegion.add(cell);
          unprocessedCells.remove(cell);

          // Add adjacent cells to the processing queue
          _addAdjacentCells(cell, unprocessedCells, cellsToProcess);
        }
      }

      regions.add(currentRegion);
    }

    return regions;
  }

  // Helper to add adjacent cells to the processing queue
  void _addAdjacentCells(
      Cell cell, Set<Cell> unprocessedCells, Set<Cell> cellsToProcess) {
    // Define adjacent cell positions (up, right, down, left)
    final adjacentPositions = [
      (cell.row - 1, cell.col), // up
      (cell.row, cell.col + 1), // right
      (cell.row + 1, cell.col), // down
      (cell.row, cell.col - 1), // left
    ];

    // For each position, find the matching cell in unprocessedCells (if any)
    for (final position in adjacentPositions) {
      // Find adjacent cells that are in the same kingdom (already filtered by being in unprocessedCells)
      for (final adjCell in unprocessedCells) {
        if (adjCell.row == position.$1 && adjCell.col == position.$2) {
          cellsToProcess.add(adjCell);
          break;
        }
      }
    }
  }

  // Helper to get ordered vertices of the kingdom outline
  List<Offset> _getOrderedKingdomVertices(Kingdom kingdom, double cellSize) {
    // 1. First get all border segments for this kingdom
    final List<BorderSegment> segments =
        _getKingdomBorderSegments(kingdom, cellSize);
    if (segments.isEmpty) return [];

    // 2. Connect segments to find vertices
    final Set<int> usedSegmentIndices = {};
    final List<Offset> orderedVertices = [];

    while (usedSegmentIndices.length < segments.length) {
      // Find the first unused segment to start
      int startIndex = -1;
      for (int i = 0; i < segments.length; i++) {
        if (!usedSegmentIndices.contains(i)) {
          startIndex = i;
          break;
        }
      }

      if (startIndex == -1) break;

      // If we already have some vertices from a previous loop, we need a clear separation
      if (orderedVertices.isNotEmpty) {
        // Create a visual separation by adding duplicate points
        // This ensures we don't try to create curves between disjoint shapes
        if (orderedVertices.length > 0) {
          orderedVertices.add(Offset.zero); // Sentinel value
        }
      }

      // Start new tracing
      final startSegment = segments[startIndex];
      usedSegmentIndices.add(startIndex);

      Offset currentPoint = startSegment.start;
      orderedVertices.add(currentPoint); // First vertex

      Offset nextPoint = startSegment.end;
      orderedVertices.add(nextPoint); // Second vertex

      currentPoint = nextPoint;
      Offset firstPoint = startSegment.start;

      // Connect segments to traverse the outline
      for (int i = 0; i < segments.length; i++) {
        int? nextIndex = _findConnectedSegmentIndex(
            segments, usedSegmentIndices, currentPoint);

        if (nextIndex != null) {
          final nextSegment = segments[nextIndex];
          usedSegmentIndices.add(nextIndex);

          // Determine next point
          if (_offsetsAreEqual(nextSegment.start, currentPoint)) {
            nextPoint = nextSegment.end;
          } else {
            nextPoint = nextSegment.start;
          }

          // Only add points that create actual corners
          if (!_pointsFormStraightLine(
              orderedVertices[orderedVertices.length - 2],
              orderedVertices[orderedVertices.length - 1],
              nextPoint)) {
            orderedVertices.add(nextPoint);
          } else {
            // Replace the previous point with this one (extend the straight line)
            orderedVertices[orderedVertices.length - 1] = nextPoint;
          }

          currentPoint = nextPoint;

          // Check if path is closed
          if (_offsetsAreEqual(currentPoint, firstPoint)) {
            // Remove the duplicate first/last vertex
            orderedVertices.removeLast();
            break;
          }
        } else {
          break;
        }
      }
    }

    return orderedVertices;
  }

  // Check if three points form a straight line
  bool _pointsFormStraightLine(Offset a, Offset b, Offset c) {
    // Calculate vectors
    final ab = Offset(b.dx - a.dx, b.dy - a.dy);
    final bc = Offset(c.dx - b.dx, c.dy - b.dy);

    // Normalize
    final abLength = sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
    final bcLength = sqrt(bc.dx * bc.dx + bc.dy * bc.dy);

    if (abLength.abs() < _epsilon || bcLength.abs() < _epsilon) return true;

    final abNorm = Offset(ab.dx / abLength, ab.dy / abLength);
    final bcNorm = Offset(bc.dx / bcLength, bc.dy / bcLength);

    // Dot product
    final dot = abNorm.dx * bcNorm.dx + abNorm.dy * bcNorm.dy;

    // If dot product close to 1, it's a straight line
    return (dot > 0.99);
  }

  // Helper to get all border segments for a kingdom
  List<BorderSegment> _getKingdomBorderSegments(
      Kingdom kingdom, double cellSize) {
    final List<BorderSegment> segments = [];
    final kingdomCellMap = <(int, int), bool>{};
    for (final cell in kingdom.cells) {
      kingdomCellMap[(cell.row, cell.col)] = true;
    }

    for (final cell in kingdom.cells) {
      final r = cell.row;
      final c = cell.col;

      // Check Top Border
      if (!kingdomCellMap.containsKey((r - 1, c))) {
        segments.add((
          start: Offset(c * cellSize, r * cellSize),
          end: Offset((c + 1) * cellSize, r * cellSize)
        ));
      }
      // Check Right Border
      if (!kingdomCellMap.containsKey((r, c + 1))) {
        segments.add((
          start: Offset((c + 1) * cellSize, r * cellSize),
          end: Offset((c + 1) * cellSize, (r + 1) * cellSize)
        ));
      }
      // Check Bottom Border
      if (!kingdomCellMap.containsKey((r + 1, c))) {
        segments.add((
          start: Offset(c * cellSize, (r + 1) * cellSize),
          end: Offset((c + 1) * cellSize, (r + 1) * cellSize)
        ));
      }
      // Check Left Border
      if (!kingdomCellMap.containsKey((r, c - 1))) {
        segments.add((
          start: Offset(c * cellSize, r * cellSize),
          end: Offset(c * cellSize, (r + 1) * cellSize)
        ));
      }
    }
    return segments;
  }

  // Helper to find the index of the next UNUSED segment connected to currentPoint
  int? _findConnectedSegmentIndex(
      List<BorderSegment> segments, Set<int> usedIndices, Offset currentPoint) {
    for (int i = 0; i < segments.length; i++) {
      if (!usedIndices.contains(i)) {
        // Check if NOT already used
        final segment = segments[i];
        if (_offsetsAreEqual(segment.start, currentPoint) ||
            _offsetsAreEqual(segment.end, currentPoint)) {
          return i;
        }
      }
    }
    return null;
  }

  // Helper for comparing offsets with tolerance
  bool _offsetsAreEqual(Offset p1, Offset p2) {
    return (p1.dx - p2.dx).abs() < _epsilon && (p1.dy - p2.dy).abs() < _epsilon;
  }

  void _drawOuterBorder(Canvas canvas) {
    final outerBorderPaint = Paint()
      ..color = outerBorderColor
      ..strokeWidth = outerBorderWidth
      ..style = PaintingStyle.stroke;

    // Create a border that's positioned completely outside the cells
    // by adjusting its position and size to be larger than the board content
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0, // Start from the very edge
        0, // Start from the very edge
        boardSize, // Full board size
        boardSize, // Full board size
      ),
      const Radius.circular(10), // Keep the same corner radius
    );
    canvas.drawRRect(borderRect, outerBorderPaint);
  }

  void _drawCellContents(Canvas canvas, double cellSize) {
    for (int r = 0; r < gameBoard.size; r++) {
      for (int c = 0; c < gameBoard.size; c++) {
        final cell = gameBoard.getCell(r, c);
        if (cell == null) continue;

        final centerX = c * cellSize + cellSize / 2;
        final centerY = r * cellSize + cellSize / 2;

        if (cell.state == CellState.queen) {
          final iconSize = cellSize * 0.55;
          // Using TextPainter to draw the icon
          final textPainter = TextPainter(
            text: TextSpan(
              text: String.fromCharCode(Icons.emoji_events.codePoint),
              style: TextStyle(
                fontSize: iconSize,
                fontFamily: 'MaterialIcons',
                color: Colors.black87,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              centerX - textPainter.width / 2,
              centerY - textPainter.height / 2,
            ),
          );
        } else if (cell.state == CellState.dot) {
          final dotPaint = Paint()..color = Colors.black54;
          final dotRadius = cellSize * 0.1;
          canvas.drawCircle(
            Offset(centerX, centerY),
            dotRadius,
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    // Basic repaint check, consider making it more granular if needed
    return oldDelegate.gameBoard != gameBoard ||
        oldDelegate.boardSize != boardSize;
  }
}
