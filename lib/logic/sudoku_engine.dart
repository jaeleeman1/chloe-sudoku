import 'dart:math';

class SudokuEngine {
  static const int size = 9;
  static const int boxSize = 3;

  /// 비어있는 9x9 그리드를 생성합니다.
  List<List<int>> generateEmptyGrid() {
    return List.generate(size, (_) => List.filled(size, 0));
  }

  /// 새로운 스도쿠 퍼즐을 생성합니다. (간단한 버전: 완성된 판을 만들고 일부를 지움)
  List<List<int>> generatePuzzle({int difficulty = 40}) {
    List<List<int>> grid = generateEmptyGrid();
    _fillGrid(grid);
    _removeNumbers(grid, difficulty);
    return grid;
  }

  /// 백트래킹을 사용하여 그리드를 숫자로 채웁니다.
  bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == 0) {
          List<int> numbers = List.generate(size, (i) => i + 1)..shuffle();
          for (int num in numbers) {
            if (isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// 특정 위치에 숫자를 넣을 수 있는지 검사합니다.
  bool isValid(List<List<int>> grid, int row, int col, int num) {
    // 행 검사
    for (int x = 0; x < size; x++) {
      if (grid[row][x] == num) return false;
    }

    // 열 검사
    for (int x = 0; x < size; x++) {
      if (grid[x][col] == num) return false;
    }

    // 3x3 박스 검사
    int startRow = row - row % boxSize;
    int startCol = col - col % boxSize;
    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        if (grid[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }

  /// 난이도에 따라 숫자를 제거합니다.
  void _removeNumbers(List<List<int>> grid, int count) {
    Random random = Random();
    int removed = 0;
    while (removed < count) {
      int row = random.nextInt(size);
      int col = random.nextInt(size);
      if (grid[row][col] != 0) {
        grid[row][col] = 0;
        removed++;
      }
    }
  }

  /// 현재 그리드가 올바른지 검증합니다. (사용자 입력 포함)
  bool isGridComplete(List<List<int>> grid) {
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        int num = grid[row][col];
        if (num == 0) return false;
        
        // 일시적으로 0으로 만들고 유효성 검사
        grid[row][col] = 0;
        if (!isValid(grid, row, col, num)) {
          grid[row][col] = num;
          return false;
        }
        grid[row][col] = num;
      }
    }
    return true;
  }
}
