import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:queens/game/models/game_board_model.dart';

// Define a simple record for cell position (or use a dedicated class)
typedef CellPosition = ({int row, int col});

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({
    required this.gameBoard, super.key,
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
  double _animationProgress = 0;
  bool _isAnimating = false;

  CellPosition?
      _tappedCellPosition; // Cell currently under finger (visual feedback)
  CellPosition? _panStartPosition; // Cell where the current pan gesture started
  final Set<CellPosition> _swipedCellsInCurrentGesture = {};

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
      Future.delayed(const Duration(milliseconds: 100), HapticFeedback.lightImpact);
      Future.delayed(const Duration(milliseconds: 200), HapticFeedback.lightImpact);
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
    _animController.forward(from: 0).then((_) {
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
        final cellSize = size / widget.gameBoard.size;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          // Remove Tap Handlers:
          // onTapDown: ...
          // onTapUp: ...
          // onTapCancel: ...

          // --- Use Pan Handlers for Tap and Swipe ---
          onPanStart: (details) {
            final pos =
                _getCellPositionFromOffset(details.localPosition, cellSize);
            if (pos != null) {
              print(
                  '🟦 onPanStart: Starting gesture at cell (${pos.row}, ${pos.col})');
              _panStartPosition = pos;
              _swipedCellsInCurrentGesture.clear();

              final cell = widget.gameBoard.getCell(pos.row, pos.col);
              if (cell != null && cell.state == CellState.empty) {
                print('🟦 onPanStart: Cell is empty, setting to dot');
                cell.state = CellState.dot;
                _swipedCellsInCurrentGesture.add(pos);
              } else {
                print(
                    '🟦 onPanStart: Cell is not empty or null, state: ${cell?.state}');
              }

              setState(() {
                _tappedCellPosition = pos;
              });
            }
          },
          onPanUpdate: (details) {
            final pos =
                _getCellPositionFromOffset(details.localPosition, cellSize);

            if (pos == null) {
              // Finger moved off board
              if (_tappedCellPosition != null) {
                setState(() {
                  _tappedCellPosition = null;
                });
              }
              return;
            }

            // Check if finger moved to a new cell
            if (pos != _tappedCellPosition) {
              // Only place dot if cell is empty and not already swiped
              if (!_swipedCellsInCurrentGesture.contains(pos)) {
                final cell = widget.gameBoard.getCell(pos.row, pos.col);
                if (cell != null && cell.state == CellState.empty) {
                  cell.state = CellState.dot;
                  _swipedCellsInCurrentGesture.add(pos);
                }
              }
              // Update visual feedback position
              setState(() {
                _tappedCellPosition = pos;
              });
            }
            // If pos == _tappedCellPosition, do nothing in update, wait for move
          },
          onPanEnd: (details) {
            final startPos = _panStartPosition;
            final currentPos = _tappedCellPosition;

            print('\n🟨 onPanEnd: Gesture ended');
            print('🟨 Start position: ${startPos?.row}, ${startPos?.col}');
            print(
                '🟨 Current position: ${currentPos?.row}, ${currentPos?.col}');
            print(
                '🟨 Swiped cells count: ${_swipedCellsInCurrentGesture.length}');
            print(
                '🟨 Swiped cells: ${_swipedCellsInCurrentGesture.map((p) => "(${p.row}, ${p.col})").join(", ")}');

            // Check if this was a single-cell gesture (tap)
            final isSameCell = startPos != null &&
                currentPos != null &&
                startPos == currentPos;

            print('🟨 Is same cell: $isSameCell');

            // If it's the same cell AND it was modified during onPanStart
            // (meaning it's in _swipedCellsInCurrentGesture), we leave it as is.
            // This keeps the dot that onPanStart placed.
            if (isSameCell && _swipedCellsInCurrentGesture.contains(startPos)) {
              print('🟨 Keeping dot placed by onPanStart');
            } else if (isSameCell) {
              // Only cycle state if it's the same cell but wasn't modified during onPanStart
              print(
                  '🟨 Cell was not modified during onPanStart, cycling state');
              final cell =
                  widget.gameBoard.getCell(startPos.row, startPos.col);
              if (cell != null) {
                print('🟨 Current cell state before cycle: ${cell.state}');
                cell.cycleState();
                print('🟨 New cell state after cycle: ${cell.state}');
              }
            } else {
              print('🟨 Not a tap - cells were different');
            }

            // Clear all gesture state
            setState(() {
              _tappedCellPosition = null;
              _panStartPosition = null;
              _swipedCellsInCurrentGesture.clear();
            });
          },
          onPanCancel: () {
            // Treat cancel like pan end - clear state
            setState(() {
              _tappedCellPosition = null;
              _panStartPosition = null;
              _swipedCellsInCurrentGesture.clear();
            });
          },

          // --- Child Painter ---
          child: CustomPaint(
            painter: GameBoardPainter(
              gameBoard: widget.gameBoard,
              boardSize: size,
              animationProgress: _animationProgress,
              tappedCellPosition: _tappedCellPosition,
            ),
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

  // Helper to calculate cell position from local offset
  CellPosition? _getCellPositionFromOffset(
      Offset localPosition, double cellSize) {
    final col = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();

    if (row >= 0 &&
        row < widget.gameBoard.size &&
        col >= 0 &&
        col < widget.gameBoard.size) {
      return (row: row, col: col);
    }
    return null;
  }
}

// Define a simple record for border segments
typedef BorderSegment = ({Offset start, Offset end});

class GameBoardPainter extends CustomPainter {
  GameBoardPainter({
    required this.gameBoard,
    required this.boardSize,
    this.animationProgress = 1.0,
    this.tappedCellPosition,
  });

  final GameBoard gameBoard;
  final double boardSize;
  final double animationProgress;
  final CellPosition? tappedCellPosition;

  // Animation thresholds (fraction of total animation)
  static const double _cellsStartThreshold = 0;
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
  static const double _contentsEndThreshold = 1; // Contents complete at 100%

  // Animation constants
  static const double _fadeInDuration =
      0.15; // Cell takes 15% of total animation time to fade in
  static const double _slideDistance = 30; // Distance in pixels to slide up

  // Constants for visual appearance
  static const Color outerBorderColor = Color(0xFF70392A);
  static const double outerBorderWidth = 3;
  static const Color kingdomBorderColor = outerBorderColor;
  static const double kingdomBorderWidth = 1.5;
  static const double _epsilon = 0.001; // Small value for float comparisons

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = boardSize / gameBoard.size;

    // Calculate board corner radius - proportional to cell size
    final boardCornerRadius = cellSize * 0.3; // 30% of cell size
    final radius = Radius.circular(
        min(boardCornerRadius, 10)); // Cap at 10.0 for large boards

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
    double backgroundAlpha = 0;
    if (animationProgress >= _backgroundStartThreshold) {
      final backgroundProgress =
          (animationProgress - _backgroundStartThreshold) /
              (_backgroundEndThreshold - _backgroundStartThreshold);
      backgroundAlpha = backgroundProgress.clamp(0.0, 1.0);

      // Draw kingdom backgrounds with the calculated opacity
      _drawKingdomBackgroundFills(canvas, cellSize, 1, backgroundAlpha);
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

  /// Calculates the outer boundary points of a kingdom for drawing borders.
  List<Offset> _getKingdomBoundaryPoints(Kingdom kingdom, double cellSize) {
    final boundaryPoints = <Offset>{};
    final cellsInKingdom = kingdom.cells.map((c) => (c.row, c.col)).toSet();
    final boardSize = gameBoard.size;

    // Iterate over all possible vertices in the grid
    for (var r = 0; r <= boardSize; r++) {
      for (var c = 0; c <= boardSize; c++) {
        // The four cells meeting at vertex (r, c)
        final topLeft = (r - 1, c - 1);
        final topRight = (r - 1, c);
        final bottomLeft = (r, c - 1);
        final bottomRight = (r, c);

        var kingdomCellsAtVertex = 0;
        if (cellsInKingdom.contains(topLeft)) kingdomCellsAtVertex++;
        if (cellsInKingdom.contains(topRight)) kingdomCellsAtVertex++;
        if (cellsInKingdom.contains(bottomLeft)) kingdomCellsAtVertex++;
        if (cellsInKingdom.contains(bottomRight)) kingdomCellsAtVertex++;

        // A vertex is on the boundary if it's shared by 1, 2, or 3 cells
        // of the same kingdom. 0 means it's outside, 4 means it's internal.
        if (kingdomCellsAtVertex > 0 && kingdomCellsAtVertex < 4) {
          boundaryPoints.add(Offset(c * cellSize, r * cellSize));
        }
      }
    }

    if (boundaryPoints.length < 3) return [];

    final List<Offset> sortedPoints = boundaryPoints.toList();

    // Calculate centroid to sort points radially
    var centroidX = 0.0;
    var centroidY = 0.0;
    for (final point in sortedPoints) {
      centroidX += point.dx;
      centroidY += point.dy;
    }
    final centroid =
        Offset(centroidX / sortedPoints.length, centroidY / sortedPoints.length);

    // Sort points by angle around the centroid
    sortedPoints.sort((a, b) {
      final angleA = atan2(a.dy - centroid.dy, a.dx - centroid.dx);
      final angleB = atan2(b.dy - centroid.dy, b.dx - centroid.dx);
      return angleA.compareTo(angleB);
    });

    return sortedPoints;
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

  void _drawKingdomBackgroundFills(
    Canvas canvas,
    double cellSize,
    double globalAlpha,
    double backgroundAlpha,
  ) {
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final kingdom in gameBoard.kingdoms) {
      // Adjust opacity based on the fade-in parameter
      fillPaint.color = kingdom.backgroundColor.withOpacity(backgroundAlpha);

      final path = Path();
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
    var cellsDrawn = 0;

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

    for (var r = 0; r < gameBoard.size; r++) {
      for (var c = 0; c < gameBoard.size; c++) {
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
    for (var i = 0; i < cellsWithContent.length; i++) {
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
      final regionVertices =
          _getKingdomRegionVertices(kingdom, cellSize);

      // Draw each region separately
      for (final vertices in regionVertices) {
        if (vertices.length < 3) continue; // Need at least 3 points for corners

        // Create a new path with rounded corners
        final roundedPath = Path();
        final n = vertices.length;

        // Process each vertex
        for (var i = 0; i < n; i++) {
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
        min(boardCornerRadius, 10)); // Cap at 10.0 for large boards

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
    final allRegionVertices = <List<Offset>>[];

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
    final regions = <List<Cell>>[];
    final unprocessedCells = Set<Cell>.from(kingdom.cells);

    while (unprocessedCells.isNotEmpty) {
      // Start a new region with the first unprocessed cell
      final startCell = unprocessedCells.first;
      final currentRegion = <Cell>[];
      final cellsToProcess = <Cell>{startCell};

      // Flood fill to find all cells connected to this region
      while (cellsToProcess.isNotEmpty) {
        final cell = cellsToProcess.first;
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
    final segments =
        _getKingdomBorderSegments(kingdom, cellSize);
    if (segments.isEmpty) return [];

    // 2. Connect segments to find vertices
    final usedSegmentIndices = <int>{};
    final orderedVertices = <Offset>[];

    while (usedSegmentIndices.length < segments.length) {
      // Find the first unused segment to start
      var startIndex = -1;
      for (var i = 0; i < segments.length; i++) {
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
        if (orderedVertices.isNotEmpty) {
          orderedVertices.add(Offset.zero); // Sentinel value
        }
      }

      // Start new tracing
      final startSegment = segments[startIndex];
      usedSegmentIndices.add(startIndex);

      var currentPoint = startSegment.start;
      orderedVertices.add(currentPoint); // First vertex

      var nextPoint = startSegment.end;
      orderedVertices.add(nextPoint); // Second vertex

      currentPoint = nextPoint;
      final firstPoint = startSegment.start;

      // Connect segments to traverse the outline
      for (var i = 0; i < segments.length; i++) {
        final nextIndex = _findConnectedSegmentIndex(
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
    return dot > 0.99;
  }

  // Helper to get all border segments for a kingdom
  List<BorderSegment> _getKingdomBorderSegments(
      Kingdom kingdom, double cellSize) {
    final borders = <BorderSegment>[];
    final kingdomCellPositions =
        kingdom.cells.map((c) => (c.row, c.col)).toSet();

    for (final cell in kingdom.cells) {
      final r = cell.row;
      final c = cell.col;

      // Check top neighbor
      if (!kingdomCellPositions.contains((r - 1, c))) {
        final start = Offset(c * cellSize, r * cellSize);
        final end = Offset((c + 1) * cellSize, r * cellSize);
        borders.add((start: start, end: end));
      }

      // Check bottom neighbor
      if (!kingdomCellPositions.contains((r + 1, c))) {
        final start = Offset(c * cellSize, (r + 1) * cellSize);
        final end = Offset((c + 1) * cellSize, (r + 1) * cellSize);
        borders.add((start: start, end: end));
      }

      // Check left neighbor
      if (!kingdomCellPositions.contains((r, c - 1))) {
        final start = Offset(c * cellSize, r * cellSize);
        final end = Offset(c * cellSize, (r + 1) * cellSize);
        borders.add((start: start, end: end));
      }

      // Check right neighbor
      if (!kingdomCellPositions.contains((r, c + 1))) {
        final start = Offset((c + 1) * cellSize, r * cellSize);
        final end = Offset((c + 1) * cellSize, (r + 1) * cellSize);
        borders.add((start: start, end: end));
      }
    }
    return borders;
  }

  // Helper to find the index of the next UNUSED segment connected to currentPoint
  int? _findConnectedSegmentIndex(
      List<BorderSegment> segments, Set<int> usedIndices, Offset currentPoint) {
    for (var i = 0; i < segments.length; i++) {
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

  // --- Queen and Dot Drawing ---

  /// Draws all the queens and dots on the board.
  void _drawContents(Canvas canvas, double cellSize, double progress) {
    if (progress <= 0) return;

    final visibleCellCount = _countVisibleCells(animationProgress);
    var drawnContentCount = 0;

    for (final kingdom in gameBoard.kingdoms) {
      for (final cell in kingdom.cells) {
        if (cell.state != CellState.empty) {
          // Calculate if this cell should be visible based on overall progress
          final isVisible = _isCellContentVisible(
            cell.row,
            cell.col,
            drawnContentCount,
            visibleCellCount,
          );

          if (isVisible) {
            switch (cell.state) {
              case CellState.queen:
                _drawQueen(canvas, cell, cellSize, progress);
              case CellState.dot:
                _drawDot(canvas, cell, cellSize, progress);
              case CellState.empty:
                break;
            }
          }
          drawnContentCount++;
        }
      }
    }
  }

  /// Calculates how many cell contents (dots/queens) should be visible
  int _countVisibleCells(double animProgress) {
    final contentProgress = (animProgress - _contentsStartThreshold) /
        (_contentsEndThreshold - _contentsStartThreshold);
    final clampedProgress = contentProgress.clamp(0.0, 1.0);

    final totalContentCells =
        gameBoard.kingdoms.fold<int>(0, (prev, k) {
      return prev +
          k.cells.where((c) => c.state != CellState.empty).length;
    });

    return (totalContentCells * clampedProgress).floor();
  }

  /// Determines if a specific cell's content should be drawn yet.
  bool _isCellContentVisible(
    int row,
    int col,
    int drawnCount,
    int visibleCount,
  ) {
    return drawnCount < visibleCount;
  }

  /// Draws a single queen in a cell.
  void _drawQueen(
    Canvas canvas,
    Cell cell,
    double cellSize,
    double progress,
  ) {
    final center = Offset(
      cell.col * cellSize + cellSize / 2,
      cell.row * cellSize + cellSize / 2,
    );

    // Use QueenIcon to draw the queen
    final iconPainter = QueenIcon(
      size: cellSize * 0.7, // 70% of cell size
      color: outerBorderColor.withOpacity(progress),
    ).painter();

    iconPainter.paint(
      canvas,
      Size(cellSize, cellSize),
    );
  }

  /// Draws a single dot in a cell.
  void _drawDot(Canvas canvas, Cell cell, double cellSize, double progress) {
    final center = Offset(
      cell.col * cellSize + cellSize / 2,
      cell.row * cellSize + cellSize / 2,
    );

    final paint = Paint()
      ..color = outerBorderColor.withOpacity(progress)
      ..style = PaintingStyle.fill;

    // Draw a circle for the dot
    canvas.drawCircle(center, cellSize * 0.2, paint); // 20% of cell size
  }

  // --- Hit-testing and Highlighting ---
  void _drawTapHighlight(Canvas canvas, double cellSize) {
    if (tappedCellPosition != null) {
      final pos = tappedCellPosition!;
      final paint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          pos.col * cellSize,
          pos.row * cellSize,
          cellSize,
          cellSize,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    // Repaint if the animation is running or if the tapped cell changes
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.tappedCellPosition != tappedCellPosition;
  }
}

class QueenIcon {
  QueenIcon({required this.size, required this.color});
  final double size;
  final Color color;

  CustomPainter painter() {
    return _QueenIconPainter(size: size, color: color);
  }
}

class _QueenIconPainter extends CustomPainter {
  _QueenIconPainter({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), size.width * 0.2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
