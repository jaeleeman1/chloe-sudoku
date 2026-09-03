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
    } else if (cell.isMemoMode) {
      backgroundColor = const Color(0xFFFFEFF2); // 옅은 파스텔 핑크색 (Light Pink)
    } else if (isRelated) {
      backgroundColor = Colors.grey[200]!;
    }

    Widget content;
    if (cell.value != 0) {
      content = Center(
        child: Text(
          '${cell.value}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    } else if (cell.memos.isNotEmpty) {
      content = Stack(
        children: [
          // 1번째: 좌측 상단 (Top-Left)
          if (cell.memos.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0, top: 1.0),
                child: Text(
                  '${cell.memos[0]}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 2번째: 우측 상단 (Top-Right)
          if (cell.memos.length > 1)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0, top: 1.0),
                child: Text(
                  '${cell.memos[1]}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 3번째: 좌측 하단 (Bottom-Left)
          if (cell.memos.length > 2)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0, bottom: 1.0),
                child: Text(
                  '${cell.memos[2]}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 4번째: 우측 하단 (Bottom-Right)
          if (cell.memos.length > 3)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0, bottom: 1.0),
                child: Text(
                  '${cell.memos[3]}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 5번째: 중간 왼쪽 (Center-Left)
          if (cell.memos.length > 4)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  '${cell.memos[4]}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
            ),
          // 6번째: 중간 오른쪽 (Center-Right)
          if (cell.memos.length > 5)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Text(
                  '${cell.memos[5]}',
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
