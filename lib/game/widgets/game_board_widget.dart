import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:queens/game/models/game_board_model.dart';
import 'package:queens/game/widgets/game_cell.dart';

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({
    super.key,
    required this.gameBoard,
    this.animate = false,
    this.enableHaptics = true,
  });

  final GameBoard gameBoard;
  final bool animate;
  final bool enableHaptics;

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _animationProgress = 0.0;
  bool _isAnimating = false;

  // Track haptic feedback stages
  bool _hasCellsHapticFired = false;
  bool _hasBackgroundHapticFired = false;
  bool _hasOuterBorderHapticFired = false;
  bool _hasKingdomBordersHapticFired = false;
  bool _hasContentsHapticFired = false;
  bool _hasCompletionHapticFired = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {
          _animationProgress = _animController.value;
          _checkAndTriggerHaptics();
        });
      });

    if (widget.animate) {
      _startAnimation();
    }
  }

  void _checkAndTriggerHaptics() {
    if (!widget.enableHaptics) return;

    // First cells appearing - light haptic feedback in quick succession
    if (_animationProgress > 0.0 && !_hasCellsHapticFired) {
      HapticFeedback.lightImpact();
      _hasCellsHapticFired = true;

      // Schedule a few quick taps for staggered feeling
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.lightImpact();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
      });
    }

    // Background appearing
    if (_animationProgress > 0.4 && !_hasBackgroundHapticFired) {
      HapticFeedback.lightImpact();
      _hasBackgroundHapticFired = true;
    }

    // Outer border appearing - medium haptic feedback
    if (_animationProgress > 0.65 && !_hasOuterBorderHapticFired) {
      HapticFeedback.mediumImpact();
      _hasOuterBorderHapticFired = true;
    }

    // Kingdom borders appearing
    if (_animationProgress > 0.75 && !_hasKingdomBordersHapticFired) {
      HapticFeedback.mediumImpact();
      _hasKingdomBordersHapticFired = true;
    }

    // Contents (queens/dots) appearing
    if (_animationProgress > 0.85 && !_hasContentsHapticFired) {
      HapticFeedback.mediumImpact();
      _hasContentsHapticFired = true;
    }

    // Animation completed - heavy haptic feedback
    if (_animationProgress >= 0.99 && !_hasCompletionHapticFired) {
      HapticFeedback.heavyImpact();
      _hasCompletionHapticFired = true;
    }
  }

  @override
  void didUpdateWidget(GameBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate && !_isAnimating) {
      _resetHapticFlags();
      _startAnimation();
    }
  }

  void _resetHapticFlags() {
    _hasCellsHapticFired = false;
    _hasBackgroundHapticFired = false;
    _hasOuterBorderHapticFired = false;
    _hasKingdomBordersHapticFired = false;
    _hasContentsHapticFired = false;
    _hasCompletionHapticFired = false;
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _animationProgress = 0.0;
      _resetHapticFlags();
    });
    _animController.forward(from: 0.0).then((_) {
      setState(() {
        _isAnimating = false;
        _animationProgress = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
            animationProgress: _animationProgress,
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
    this.animationProgress = 1.0,
  });

  final GameBoard gameBoard;
  final double boardSize;
  final double animationProgress;

  // Animation thresholds (fraction of total animation)
  static const double _cellsStartThreshold = 0.0;
  static const double _cellsEndThreshold =
      0.5; // Cells appear during first 50% of animation
  static const double _backgroundStartThreshold =
      0.4; // Background starts fading in at 40%
  static const double _backgroundEndThreshold =
      0.6; // Background completes at 60%
  static const double _outerBorderThreshold =
      0.65; // Outer border appears at 65%
  static const double _kingdomBordersThreshold =
      0.75; // Kingdom borders appear at 75%
  static const double _contentsStartThreshold =
      0.85; // Contents (dots/queens) start at 85%
  static const double _contentsEndThreshold = 1.0; // Contents complete at 100%

  // Animation constants
  static const double _fadeInDuration =
      0.15; // Cell takes 15% of total animation time to fade in
  static const double _slideDistance = 30.0; // Distance in pixels to slide up

  // Constants for visual appearance
  static const Color outerBorderColor = Color(0xFF70392A);
  static const double outerBorderWidth = 3.0;
  static const Color kingdomBorderColor = outerBorderColor;
  static const double kingdomBorderWidth = 1.5;
  static const double _epsilon = 0.001; // Small value for float comparisons

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = boardSize / gameBoard.size;

    // Calculate board corner radius - proportional to cell size
    final boardCornerRadius = cellSize * 0.3; // 30% of cell size
    final radius = Radius.circular(
        min(boardCornerRadius, 10.0)); // Cap at 10.0 for large boards

    // Save the canvas state before applying clipping
    canvas.save();

    // Define the clip region with same rounded corners as the outer border
    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, boardSize, boardSize),
        radius,
      ));

    // Apply the clip to ensure all content stays within the rounded border
    canvas.clipPath(clipPath);

    // Always draw the white background
    _drawBoardBackground(canvas);

    // Draw kingdom backgrounds first - behind the cells
    double backgroundAlpha = 0.0;
    if (animationProgress >= _backgroundStartThreshold) {
      final backgroundProgress =
          (animationProgress - _backgroundStartThreshold) /
              (_backgroundEndThreshold - _backgroundStartThreshold);
      backgroundAlpha = backgroundProgress.clamp(0.0, 1.0);

      // Draw kingdom backgrounds with the calculated opacity
      _drawKingdomBackgroundFills(canvas, cellSize, 1.0, backgroundAlpha);
    }

    // Draw staggered cell animations ON TOP of the backgrounds
    if (animationProgress > _cellsStartThreshold) {
      // Calculate how far into the cell animation we are
      final cellAnimProgress = (animationProgress - _cellsStartThreshold) /
          (_cellsEndThreshold - _cellsStartThreshold);
      final cellAnimClamped = cellAnimProgress.clamp(0.0, 1.0);

      if (cellAnimClamped > 0) {
        _drawCells(canvas, cellSize, cellAnimClamped);
      }
    }

    // Restore canvas state before drawing borders
    canvas.restore();

    // Draw the outer border with fade-in animation when its threshold is reached
    if (animationProgress >= _outerBorderThreshold) {
      final borderProgress = (animationProgress - _outerBorderThreshold) /
          (1.0 - _outerBorderThreshold);
      _drawOuterBorder(canvas, borderProgress.clamp(0.0, 1.0));
    }

    // Draw the kingdom borders with fade-in animation when their threshold is reached
    if (animationProgress >= _kingdomBordersThreshold) {
      final borderProgress = (animationProgress - _kingdomBordersThreshold) /
          (_contentsStartThreshold - _kingdomBordersThreshold);

      // Save canvas state for kingdom border clipping
      canvas.save();
      canvas.clipPath(clipPath);

      // Adjust the opacity of borders for fade-in effect
      final kingdomBorderAlpha = (borderProgress.clamp(0.0, 1.0) * 255).toInt();

      _drawTrulyRoundedKingdomBorders(canvas, cellSize, kingdomBorderAlpha);
      canvas.restore();
    }

    // Draw cell contents (dots/queens) last
    if (animationProgress >= _contentsStartThreshold) {
      final contentProgress = (animationProgress - _contentsStartThreshold) /
          (_contentsEndThreshold - _contentsStartThreshold);
      final contentClamped = contentProgress.clamp(0.0, 1.0);

      // Save canvas state for cell content clipping
      canvas.save();
      canvas.clipPath(clipPath);

      _drawCellContents(canvas, cellSize, contentClamped);

      canvas.restore();
    }
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

  void _drawKingdomBackgroundFills(Canvas canvas, double cellSize,
      [double animProgress = 1.0, double opacity = 1.0]) {
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final kingdom in gameBoard.kingdoms) {
      // Adjust opacity based on the fade-in parameter
      fillPaint.color = kingdom.backgroundColor.withOpacity(opacity);

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

  void _drawCells(Canvas canvas, double cellSize, [double animProgress = 1.0]) {
    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Calculate proportional corner radius based on cell size
    final cellCornerRadius =
        cellSize * 0.15; // 15% of cell size for rounded corners

    // Calculate the total number of cells for animation
    final totalCells = gameBoard.kingdoms
        .fold<int>(0, (sum, kingdom) => sum + kingdom.cells.length);

    // Count cells that should have visible based on animation progress
    final visibleCellCount = (totalCells * animProgress).round();

    // Counter to track how many cells we've drawn
    int cellsDrawn = 0;

    for (final kingdom in gameBoard.kingdoms) {
      fillPaint.color = kingdom.color;

      for (final cell in kingdom.cells) {
        // If we've drawn too many cells already, break out
        if (cellsDrawn >= totalCells) break;

        // Calculate individual cell animation progress
        final cellStartTime = cellsDrawn / totalCells * _cellsEndThreshold;
        final cellProgress = (animProgress - cellStartTime) / _fadeInDuration;
        final clampedProgress = cellProgress.clamp(0.0, 1.0);

        if (clampedProgress > 0) {
          // Apply opacity based on cell progress
          fillPaint.color = kingdom.color.withOpacity(clampedProgress);

          // Calculate the vertical offset for slide-up animation
          final slideOffset = _slideDistance * (1 - clampedProgress);

          final cellRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              cell.col * cellSize + 0.5,
              cell.row * cellSize + 0.5 + slideOffset,
              cellSize - 1.0,
              cellSize - 1.0,
            ),
            Radius.circular(cellCornerRadius),
          );
          canvas.drawRRect(cellRect, fillPaint);
        }

        cellsDrawn++;
      }
    }
  }

  void _drawCellContents(Canvas canvas, double cellSize,
      [double animProgress = 1.0]) {
    // Calculate the total number of cells with content
    final cellsWithContent = <(int, int)>[];

    for (int r = 0; r < gameBoard.size; r++) {
      for (int c = 0; c < gameBoard.size; c++) {
        final cell = gameBoard.getCell(r, c);
        if (cell != null && cell.state != CellState.empty) {
          cellsWithContent.add((r, c));
        }
      }
    }

    // Count cells that should be visible based on animation progress
    final visibleContentCount =
        (cellsWithContent.length * animProgress).round();

    // Draw only the visible cell contents
    for (int i = 0; i < cellsWithContent.length; i++) {
      final r = cellsWithContent[i].$1;
      final c = cellsWithContent[i].$2;
      final cell = gameBoard.getCell(r, c);
      if (cell == null) continue;

      // Calculate individual cell content animation progress
      final cellStartTime = i / cellsWithContent.length * _cellsEndThreshold;
      final cellProgress = (animProgress - cellStartTime) / _fadeInDuration;
      final clampedProgress = cellProgress.clamp(0.0, 1.0);

      if (clampedProgress <= 0) continue;

      final centerX = c * cellSize + cellSize / 2;
      final centerY = r * cellSize + cellSize / 2;

      // Calculate the vertical offset for slide-up animation
      final slideOffset = _slideDistance * (1 - clampedProgress);

      if (cell.state == CellState.queen) {
        final iconSize = cellSize * 0.55;
        final textPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.emoji_events.codePoint),
            style: TextStyle(
              fontSize: iconSize,
              fontFamily: 'MaterialIcons',
              color: Colors.black87.withOpacity(clampedProgress),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            centerY - textPainter.height / 2 + slideOffset,
          ),
        );
      } else if (cell.state == CellState.dot) {
        final dotPaint = Paint()
          ..color = Colors.black54.withOpacity(clampedProgress);
        final dotRadius = cellSize * 0.1;
        canvas.drawCircle(
          Offset(centerX, centerY + slideOffset),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  void _drawTrulyRoundedKingdomBorders(Canvas canvas, double cellSize,
      [int alpha = 255]) {
    // Use the original kingdom border color with the specified alpha
    final borderColor = kingdomBorderColor.withAlpha(alpha);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = kingdomBorderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Corner radius - adjust based on cell size for consistency
    // Make it proportional to the cell size (25% of cell size)
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

  void _drawOuterBorder(Canvas canvas, [double opacity = 1.0]) {
    final outerBorderPaint = Paint()
      ..color = outerBorderColor.withOpacity(opacity)
      ..strokeWidth = outerBorderWidth
      ..style = PaintingStyle.stroke;

    // Calculate board corner radius - proportional to cell size
    final cellSize = boardSize / gameBoard.size;
    final boardCornerRadius = cellSize * 0.3; // 30% of cell size
    final radius = Radius.circular(
        min(boardCornerRadius, 10.0)); // Cap at 10.0 for large boards

    // Create a border that's positioned completely outside the cells
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0, // Start from the very edge
        0, // Start from the very edge
        boardSize, // Full board size
        boardSize, // Full board size
      ),
      radius,
    );
    canvas.drawRRect(borderRect, outerBorderPaint);
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

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    return oldDelegate.gameBoard != gameBoard ||
        oldDelegate.boardSize != boardSize ||
        oldDelegate.animationProgress != animationProgress;
  }
}
