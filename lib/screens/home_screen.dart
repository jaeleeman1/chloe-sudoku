import 'dart:async';
import 'package:flutter/material.dart';
import '../logic/sudoku_engine.dart';
import '../models/sudoku_grid.dart';
import '../widgets/sudoku_cell.dart';
import '../widgets/number_pad.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SudokuEngine _engine = SudokuEngine();
  late SudokuGrid _grid;
  int? _selectedRow;
  int? _selectedCol;

  String _currentDifficulty = '초급';

  DateTime? _startTime;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // 메모 모드 글로벌 상태
  bool _isGlobalMemoMode = false;

  // Undo (되돌리기) 히스토리 스택
  final List<SudokuGrid> _undoHistory = [];

  int get _difficultyRemovedCount {
    switch (_currentDifficulty) {
      case '초급':
        return 30;
      case '중급':
        return 42;
      case '고급':
        return 52;
      default:
        return 30;
    }
  }

  int get _difficultyMultiplier {
    switch (_currentDifficulty) {
      case '초급':
        return 1;
      case '중급':
        return 2;
      case '고급':
        return 3;
      default:
        return 1;
    }
  }

  Set<int> get _completedNumbers {
    Map<int, int> counts = {};
    for (var row in _grid.cells) {
      for (var cell in row) {
        if (cell.value != 0 && !cell.isInvalid) {
          counts[cell.value] = (counts[cell.value] ?? 0) + 1;
        }
      }
    }
    Set<int> completed = {};
    counts.forEach((num, count) {
      if (count >= 9) {
        completed.add(num);
      }
    });
    return completed;
  }

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _saveHistory() {
    _undoHistory.add(_grid.copy());
    if (_undoHistory.length > 50) {
      _undoHistory.removeAt(0);
    }
  }

  void _startNewGame() {
    _timer?.cancel();
    _startTime = DateTime.now();
    _elapsedSeconds = 0;
    _undoHistory.clear();
    _isGlobalMemoMode = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    setState(() {
      _grid = SudokuGrid.fromIntGrid(
        _engine.generatePuzzle(difficulty: _difficultyRemovedCount),
      );
      _selectedRow = null;
      _selectedCol = null;
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final hours = totalSeconds ~/ 3600;
    if (hours > 0) {
      final remainingMinutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      return '$hours:$remainingMinutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _onCellTap(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;

      if (_isGlobalMemoMode && _selectedRow != null && _selectedCol != null) {
        SudokuCell cell = _grid.cells[_selectedRow!][_selectedCol!];
        if (!cell.isFixed && cell.value == 0) {
          cell.isMemoMode = true;
        }
      }
    });
  }

  void _autoRemoveMemoNumbers(int r, int c, int number) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (row == r && col == c) continue;

        bool isSameRow = (row == r);
        bool isSameCol = (col == c);
        bool isSameBox = (row ~/ 3 == r ~/ 3) && (col ~/ 3 == c ~/ 3);

        if (isSameRow || isSameCol || isSameBox) {
          SudokuCell targetCell = _grid.cells[row][col];
          if (targetCell.memos.contains(number)) {
            targetCell.memos.remove(number);
            if (targetCell.memos.isEmpty) {
              targetCell.isMemoMode = false;
            }
          }
        }
      }
    }
  }

  void _onNumberSelected(int number) {
    if (_selectedRow != null && _selectedCol != null) {
      SudokuCell targetCell = _grid.cells[_selectedRow!][_selectedCol!];
      if (targetCell.isFixed) return;

      _saveHistory();

      setState(() {
        if (_isGlobalMemoMode) {
          // 메모 모드가 활성화되어 있을 때 -> 후보 메모 숫자 입력
          targetCell.isMemoMode = true;
          if (targetCell.memos.contains(number)) {
            targetCell.memos.remove(number);
            if (targetCell.memos.isEmpty) {
              targetCell.isMemoMode = false;
            }
          } else if (targetCell.memos.length < 9) {
            targetCell.memos.add(number);
          }
        } else {
          // 메모 버튼을 한번 더 눌러 일반 모드로 전환된 상태 -> 일반 표준 숫자 입력
          // 기존에 메모나 핑크색이 있었다면 모두 사라지고 일반 숫자가 입력됨!
          _grid.set(_selectedRow!, _selectedCol!, number);
          _autoRemoveMemoNumbers(_selectedRow!, _selectedCol!, number);
          _validateGrid();
          _checkCompletion();
        }
      });
    }
  }

  void _onToggleMemoMode() {
    setState(() {
      _isGlobalMemoMode = !_isGlobalMemoMode;
      if (_selectedRow != null && _selectedCol != null) {
        SudokuCell targetCell = _grid.cells[_selectedRow!][_selectedCol!];
        if (!targetCell.isFixed && targetCell.value == 0) {
          if (_isGlobalMemoMode) {
            targetCell.isMemoMode = true;
          } else if (targetCell.memos.isEmpty) {
            targetCell.isMemoMode = false;
          }
        }
      }
    });
  }

  void _onClear() {
    if (_selectedRow != null && _selectedCol != null) {
      SudokuCell targetCell = _grid.cells[_selectedRow!][_selectedCol!];
      if (!targetCell.isFixed) {
        _saveHistory();
        setState(() {
          _grid.set(_selectedRow!, _selectedCol!, 0);
          targetCell.isMemoMode = false;
          targetCell.memos.clear();
          _validateGrid();
        });
      }
    }
  }

  void _onUndo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _grid = _undoHistory.removeLast();
        _validateGrid();
      });
    }
  }

  void _validateGrid() {
    _grid.resetInvalidStates();
    List<List<int>> currentIntGrid = _grid.toIntGrid();
    
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        int val = currentIntGrid[r][c];
        if (val != 0) {
          currentIntGrid[r][c] = 0;
          if (!_engine.isValid(currentIntGrid, r, c, val)) {
            _grid.cells[r][c].isInvalid = true;
          }
          currentIntGrid[r][c] = val;
        }
      }
    }
  }

  int _getBaseScore(String difficulty) {
    switch (difficulty) {
      case '초급':
        return 100;
      case '중급':
        return 300;
      case '고급':
        return 600;
      default:
        return 100;
    }
  }

  int _calculateFinalScore(int totalSeconds) {
    int baseScore = _getBaseScore(_currentDifficulty);
    int targetSeconds;

    switch (_currentDifficulty) {
      case '초급':
        targetSeconds = 180;
        break;
      case '중급':
        targetSeconds = 360;
        break;
      case '고급':
        targetSeconds = 600;
        break;
      default:
        targetSeconds = 180;
    }

    if (totalSeconds <= targetSeconds) {
      return baseScore + (targetSeconds - totalSeconds);
    } else {
      int penalty = totalSeconds - targetSeconds;
      int score = baseScore - penalty;
      return score < 0 ? 0 : score;
    }
  }

  void _checkCompletion() {
    if (_engine.isGridComplete(_grid.toIntGrid())) {
      _timer?.cancel();
      int baseScore = _getBaseScore(_currentDifficulty);
      int calculatedScore = _calculateFinalScore(_elapsedSeconds);
      int multiplier = _difficultyMultiplier;
      int finalScore = calculatedScore * multiplier;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 축하 헤더 아이콘
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '축하합니다!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '스도쿠를 성공적으로 완성하셨습니다 🎉',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                // 결과 카드 (파란색 테마)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow('난이도', '$_currentDifficulty', Colors.blue.shade900),
                      const Divider(height: 16, thickness: 1),
                      _buildResultRow('경과 시간', _formatDuration(_elapsedSeconds), Colors.black87),
                      const Divider(height: 16, thickness: 1),
                      _buildResultRow('최종 점수', '$finalScore점 ⭐', Colors.indigo.shade900, isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 새 게임 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startNewGame();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    label: const Text(
                      '새 게임 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildResultRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.blue.shade900,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String level, IconData icon, Color iconColor) {
    bool isSelected = _currentDifficulty == level;
    return PopupMenuItem<String>(
      value: level,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.blue.shade900 : iconColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade900 : Colors.blue.shade800,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 16, color: Colors.blue.shade800),
          ],
        ),
      ),
    );
  }

  bool _isRelated(int r, int c) {
    if (_selectedRow == null || _selectedCol == null) return false;
    if (r == _selectedRow && c == _selectedCol) return false;

    if (r == _selectedRow || c == _selectedCol) return true;

    int selectedVal = _grid.get(_selectedRow!, _selectedCol!);
    if (selectedVal != 0 && _grid.get(r, c) == selectedVal) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.grid_3x3_rounded,
                color: Colors.blue.shade900,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.indigo.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'Chloe Sudoku',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: OutlinedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Game'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxBoardHeight = constraints.maxHeight - 200;
            if (maxBoardHeight < 200) maxBoardHeight = 200;
            double boardSize = (constraints.maxWidth - 16) < maxBoardHeight ? (constraints.maxWidth - 16) : maxBoardHeight;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 난이도 선택 버튼
                              PopupMenuButton<String>(
                                initialValue: _currentDifficulty,
                                onSelected: (String level) {
                                  if (_currentDifficulty != level) {
                                    setState(() {
                                      _currentDifficulty = level;
                                      _startNewGame();
                                    });
                                  }
                                },
                                color: Colors.blue.shade50,
                                elevation: 6,
                                shadowColor: Colors.blue.shade200.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.blue.shade200, width: 1.0),
                                ),
                                itemBuilder: (context) => [
                                  _buildMenuItem('초급', Icons.sentiment_satisfied_alt, Colors.blue.shade600),
                                  _buildMenuItem('중급', Icons.sentiment_neutral, Colors.indigo.shade600),
                                  _buildMenuItem('고급', Icons.local_fire_department, Colors.deepPurple.shade600),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blue.shade300, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.shade100,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentDifficulty,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.arrow_drop_down, color: Colors.blue.shade800, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              // 점수 (스코어) & 툴팁/팝업
                              Tooltip(
                                message: '🏆 점수 산출 규칙 (기본 점수 / 기준시간)\n'
                                    '• 초급: 100점 / 3분 (180초)\n'
                                    '• 중급: 300점 / 6분 (360초)\n'
                                    '• 고급: 600점 / 10분 (600초)\n\n'
                                    '⭐ 점수 계산 방식\n'
                                    '• 기준 시간 이내 성공: 기본 점수 + (기준 시간 - 해결 시간)\n'
                                    '• 기준 시간 이후 성공: 기본 점수 - (해결 시간 - 기준 시간)\n'
                                    '• 실패/새로고침: 0점 처리',
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade900.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                preferBelow: false,
                                triggerMode: TooltipTriggerMode.tap,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.stars_rounded, size: 18, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '기본 점수: ${_getBaseScore(_currentDifficulty)}점',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(Icons.info_outline, size: 14, color: Colors.amber.shade900),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 경과 시간
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: Colors.deepOrange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '경과: ${_formatDuration(_elapsedSeconds)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 81,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 9,
                              ),
                              itemBuilder: (context, index) {
                                int r = index ~/ 9;
                                int c = index % 9;
                                return SudokuCellWidget(
                                  cell: _grid.cells[r][c],
                                  row: r,
                                  col: c,
                                  isSelected: r == _selectedRow && c == _selectedCol,
                                  isRelated: _isRelated(r, c),
                                  onTap: () => _onCellTap(r, c),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 메모 & 되돌리기 버튼 (숫자 패드 바로 위)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _onToggleMemoMode,
                                icon: Icon(
                                  Icons.edit_note,
                                  color: _isGlobalMemoMode ? Colors.pink.shade700 : Colors.blue.shade700,
                                ),
                                label: Text(
                                  '메모',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isGlobalMemoMode ? Colors.pink.shade700 : Colors.blue.shade800,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _isGlobalMemoMode ? const Color(0xFFFFEFF2) : Colors.white,
                                  side: BorderSide(
                                    color: _isGlobalMemoMode ? Colors.pink.shade300 : Colors.blue.shade300,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _undoHistory.isNotEmpty ? _onUndo : null,
                                icon: Icon(
                                  Icons.undo_rounded,
                                  color: _undoHistory.isNotEmpty ? Colors.blue.shade700 : Colors.grey,
                                ),
                                label: Text(
                                  '되돌리기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _undoHistory.isNotEmpty ? Colors.blue.shade800 : Colors.grey,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: _undoHistory.isNotEmpty ? Colors.blue.shade300 : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      NumberPad(
                        onNumberSelected: _onNumberSelected,
                        onClear: _onClear,
                        completedNumbers: _completedNumbers,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
