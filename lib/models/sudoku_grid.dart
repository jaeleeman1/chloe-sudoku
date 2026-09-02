class SudokuCell {
  int value;
  final bool isFixed; // 처음부터 주어진 숫자인지 여부
  bool isInvalid;     // 현재 규칙에 어긋나는지 여부

  SudokuCell({
    required this.value,
    required this.isFixed,
    this.isInvalid = false,
  });
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

  int get(int row, int col) => cells[row][col].value;

  void set(int row, int col, int value) {
    if (!cells[row][col].isFixed) {
      cells[row][col].value = value;
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
