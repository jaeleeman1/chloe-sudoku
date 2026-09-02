import 'package:flutter/material.dart';
import '../models/sudoku_grid.dart';

class SudokuCellWidget extends StatelessWidget {
  final SudokuCell cell;
  final int row;
  final int col;
  final bool isSelected;
  final bool isRelated;
  final VoidCallback onTap;

  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.row,
    required this.col,
    required this.isSelected,
    required this.isRelated,
    required this.onTap,
  });

  BorderSide _getTopBorder() {
    if (row == 0) {
      return const BorderSide(color: Colors.black, width: 2.0);
    } else if (row % 3 == 0) {
      return BorderSide(color: Colors.grey[600]!, width: 1.0);
    } else {
      return BorderSide(color: Colors.grey[300]!, width: 0.5);
    }
  }

  BorderSide _getLeftBorder() {
    if (col == 0) {
      return const BorderSide(color: Colors.black, width: 2.0);
    } else if (col % 3 == 0) {
      return BorderSide(color: Colors.grey[600]!, width: 1.0);
    } else {
      return BorderSide(color: Colors.grey[300]!, width: 0.5);
    }
  }

  BorderSide _getRightBorder() {
    if (col == 8) {
      return const BorderSide(color: Colors.black, width: 2.0);
    } else if ((col + 1) % 3 == 0) {
      return BorderSide(color: Colors.grey[600]!, width: 1.0);
    } else {
      return BorderSide(color: Colors.grey[300]!, width: 0.5);
    }
  }

  BorderSide _getBottomBorder() {
    if (row == 8) {
      return const BorderSide(color: Colors.black, width: 2.0);
    } else if ((row + 1) % 3 == 0) {
      return BorderSide(color: Colors.grey[600]!, width: 1.0);
    } else {
      return BorderSide(color: Colors.grey[300]!, width: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = cell.isFixed ? Colors.black : Colors.blue[800]!;
    if (cell.isInvalid) textColor = Colors.red;

    Color backgroundColor = Colors.white;
    if (isSelected) {
      backgroundColor = Colors.blue[200]!;
    } else if (isRelated) {
      backgroundColor = Colors.blue[50]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: _getTopBorder(),
            left: _getLeftBorder(),
            right: _getRightBorder(),
            bottom: _getBottomBorder(),
          ),
        ),
        child: Center(
          child: Text(
            cell.value == 0 ? '' : '${cell.value}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
