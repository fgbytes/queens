import 'package:flutter/material.dart';

class QueenIcon extends StatelessWidget {
  const QueenIcon({
    super.key,
    required this.size,
    this.color = Colors.black87,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: QueenIconPainter(color: color),
      ),
    );
  }
}

class QueenIconPainter extends CustomPainter {
  QueenIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Draw a crown shape more similar to the reference image
    // Reference image shows a chess-like crown with 5 points/spikes

    // Base points for the crown
    final double baseY = size.height * 0.75;
    final double maxHeight = size.height * 0.20; // Height of tallest spike

    // Create 5 spikes at the top of the crown
    final List<Offset> basePoints = [
      Offset(size.width * 0.15, baseY), // Left edge
      Offset(size.width * 0.30, baseY),
      Offset(size.width * 0.50, baseY), // Center
      Offset(size.width * 0.70, baseY),
      Offset(size.width * 0.85, baseY), // Right edge
    ];

    final List<Offset> tipPoints = [
      Offset(size.width * 0.15, baseY - maxHeight * 0.9), // Left spike
      Offset(size.width * 0.30, baseY - maxHeight * 0.75),
      Offset(size.width * 0.50, baseY - maxHeight), // Center spike (tallest)
      Offset(size.width * 0.70, baseY - maxHeight * 0.75),
      Offset(size.width * 0.85, baseY - maxHeight * 0.9), // Right spike
    ];

    // Draw the crown base
    final Path basePath = Path()
      ..moveTo(size.width * 0.10, baseY)
      ..lineTo(size.width * 0.90, baseY)
      ..lineTo(size.width * 0.80, baseY + size.height * 0.15)
      ..lineTo(size.width * 0.20, baseY + size.height * 0.15)
      ..close();

    canvas.drawPath(basePath, paint);

    // Draw the spikes
    for (int i = 0; i < basePoints.length; i++) {
      // Draw line from base to tip
      canvas.drawLine(basePoints[i], tipPoints[i], strokePaint);

      // Draw a small circle at the tip
      canvas.drawCircle(
        tipPoints[i],
        size.width * 0.06,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
