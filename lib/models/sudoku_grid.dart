class SudokuCell {
  int value;
  final bool isFixed; // 처음부터 주어진 숫자인지 여부
  bool isInvalid;     // 현재 규칙에 어긋나는지 여부
  bool isMemoMode;    // 메모(핑크색) 모드 여부
  List<int> memos;    // 메모로 작성된 숫자들 (최대 2개)

  SudokuCell({
    required this.value,
    required this.isFixed,
    this.isInvalid = false,
    this.isMemoMode = false,
    List<int>? memos,
  }) : memos = memos ?? [];

  SudokuCell copy() {
    return SudokuCell(
      value: value,
      isFixed: isFixed,
      isInvalid: isInvalid,
      isMemoMode: isMemoMode,
      memos: List<int>.from(memos),
    );
  }
}

class SudokuGrid {
  late List<List<SudokuCell>> cells;

  SudokuGrid.fromIntGrid(List<List<int>> grid) {
    cells = List.generate(9, (r) {
      return List.generate(9, (c) {
        return SudokuCell(
          value: grid[r][c],
          isFixed: grid[r][c] != 0,
        );
      });
    });
  }

  SudokuGrid.fromCells(List<List<SudokuCell>> otherCells) {
    cells = List.generate(9, (r) {
      return List.generate(9, (c) => otherCells[r][c].copy());
    });
  }

  SudokuGrid copy() {
    return SudokuGrid.fromCells(cells);
  }

  int get(int row, int col) => cells[row][col].value;

  void set(int row, int col, int value) {
    if (!cells[row][col].isFixed) {
      cells[row][col].value = value;
      if (value != 0) {
        cells[row][col].isMemoMode = false;
        cells[row][col].memos.clear();
      }
    }
  }

  void resetInvalidStates() {
    for (var row in cells) {
      for (var cell in row) {
        cell.isInvalid = false;
      }
    }
  }

  List<List<int>> toIntGrid() {
    return List.generate(9, (r) => List.generate(9, (c) => cells[r][c].value));
  }
}
