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
      return const BorderSide(color: Color(0xFF776E65), width: 2.5);
    } else if (row % 3 == 0) {
      return const BorderSide(color: Color(0xFF776E65), width: 1.5);
    } else {
      return const BorderSide(color: Color(0xFFD6CDC4), width: 0.8);
    }
  }

  BorderSide _getLeftBorder() {
    if (col == 0) {
      return const BorderSide(color: Color(0xFF776E65), width: 2.5);
    } else if (col % 3 == 0) {
      return const BorderSide(color: Color(0xFF776E65), width: 1.5);
    } else {
      return const BorderSide(color: Color(0xFFD6CDC4), width: 0.8);
    }
  }

  BorderSide _getRightBorder() {
    if (col == 8) {
      return const BorderSide(color: Color(0xFF776E65), width: 2.5);
    } else if ((col + 1) % 3 == 0) {
      return const BorderSide(color: Color(0xFF776E65), width: 1.5);
    } else {
      return const BorderSide(color: Color(0xFFD6CDC4), width: 0.8);
    }
  }

  BorderSide _getBottomBorder() {
    if (row == 8) {
      return const BorderSide(color: Color(0xFF776E65), width: 2.5);
    } else if ((row + 1) % 3 == 0) {
      return const BorderSide(color: Color(0xFF776E65), width: 1.5);
    } else {
      return const BorderSide(color: Color(0xFFD6CDC4), width: 0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = cell.isFixed ? const Color(0xFF776E65) : const Color(0xFF8F7A66);
    if (cell.isInvalid) textColor = Colors.red.shade700;

    Color backgroundColor = Colors.white;
    if (isSelected) {
      backgroundColor = const Color(0xFFF2B179); // Warm 2048 Amber Highlight
    } else if (isRelated) {
      backgroundColor = const Color(0xFFEEE4DA); // Soft Cream Cross Highlight
    }

    Widget content;
    if (cell.value != 0) {
      content = Center(
        child: Text(
          '${cell.value}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: cell.isFixed ? FontWeight.w900 : FontWeight.bold,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      );
    } else if (cell.memos.isNotEmpty) {
      content = Stack(
        children: [
          // 1번: 좌측 상단 (Top-Left)
          if (cell.memos.contains(1))
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0, top: 1.0),
                child: Text(
                  '1',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 2번: 상단 가운데 (Top-Center)
          if (cell.memos.contains(2))
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Text(
                  '2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 3번: 우측 상단 (Top-Right)
          if (cell.memos.contains(3))
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0, top: 1.0),
                child: Text(
                  '3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 4번: 중간 왼쪽 (Center-Left)
          if (cell.memos.contains(4))
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  '4',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 5번: 중간 가운데 (Center-Center)
          if (cell.memos.contains(5))
            Align(
              alignment: Alignment.center,
              child: Text(
                '5',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade800,
                ),
              ),
            ),
          // 6번: 중간 오른쪽 (Center-Right)
          if (cell.memos.contains(6))
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Text(
                  '6',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 7번: 좌측 하단 (Bottom-Left)
          if (cell.memos.contains(7))
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0, bottom: 1.0),
                child: Text(
                  '7',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 8번: 하단 가운데 (Bottom-Center)
          if (cell.memos.contains(8))
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Text(
                  '8',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 9번: 우측 하단 (Bottom-Right)
          if (cell.memos.contains(9))
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0, bottom: 1.0),
                child: Text(
                  '9',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      content = const SizedBox.shrink();
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
        child: content,
      ),
    );
  }
}
