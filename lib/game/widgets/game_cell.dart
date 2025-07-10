import 'package:flutter/material.dart';
import 'package:queens/game/models/game_board_model.dart';

class GameCell extends StatelessWidget {
  const GameCell({
    required this.cell, required this.size, required this.onTap, super.key,
    this.backgroundColor,
    this.borderColor = Colors.grey,
    this.borderWidth = 0.5,
    this.showBorderTop = true,
    this.showBorderRight = true,
    this.showBorderBottom = true,
    this.showBorderLeft = true,
    this.kingdomBorderColor,
    this.kingdomBorderWidth = 1.5,
    this.showKingdomBorderTop = false,
    this.showKingdomBorderRight = false,
    this.showKingdomBorderBottom = false,
    this.showKingdomBorderLeft = false,
  });

  final Cell cell;
  final double size;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool showBorderTop;
  final bool showBorderRight;
  final bool showBorderBottom;
  final bool showBorderLeft;

  final Color? kingdomBorderColor;
  final double kingdomBorderWidth;
  final bool showKingdomBorderTop;
  final bool showKingdomBorderRight;
  final bool showKingdomBorderBottom;
  final bool showKingdomBorderLeft;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Background container with thin grid lines
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: showBorderTop
                        ? BorderSide(color: borderColor, width: borderWidth)
                        : BorderSide.none,
                    right: showBorderRight
                        ? BorderSide(color: borderColor, width: borderWidth)
                        : BorderSide.none,
                    bottom: showBorderBottom
                        ? BorderSide(color: borderColor, width: borderWidth)
                        : BorderSide.none,
                    left: showBorderLeft
                        ? BorderSide(color: borderColor, width: borderWidth)
                        : BorderSide.none,
                  ),
                ),
              ),
            ),

            // Kingdom borders
            if (kingdomBorderColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: showKingdomBorderTop
                          ? BorderSide(
                              color: kingdomBorderColor!,
                              width: kingdomBorderWidth)
                          : BorderSide.none,
                      right: showKingdomBorderRight
                          ? BorderSide(
                              color: kingdomBorderColor!,
                              width: kingdomBorderWidth)
                          : BorderSide.none,
                      bottom: showKingdomBorderBottom
                          ? BorderSide(
                              color: kingdomBorderColor!,
                              width: kingdomBorderWidth)
                          : BorderSide.none,
                      left: showKingdomBorderLeft
                          ? BorderSide(
                              color: kingdomBorderColor!,
                              width: kingdomBorderWidth)
                          : BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Cell content (centered)
            Positioned.fill(
              child: Center(
                child: _buildCellContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    switch (cell.state) {
      case CellState.empty:
        return const SizedBox.shrink();
      case CellState.dot:
        return Container(
          width: size * 0.2,
          height: size * 0.2,
          decoration: BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
          ),
        );
      case CellState.queen:
        return Icon(
          Icons.emoji_events, // Trophy icon, looks more like a crown/queen
          // Other good options:
          // Icons.stars - Star burst icon (crown-like)
          // Icons.auto_awesome - Sparkle/magic wand (royal)
          // Icons.workspace_premium - Medal/badge icon
          // Icons.diamond - Diamond shape
          // Icons.military_tech - Military badge/medal
          size: size * 0.55,
          color: Colors.black87,
        );
    }
  }
}
