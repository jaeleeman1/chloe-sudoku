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

  // 최고점수 스코어
  int _bestScore = 0;

  // 메모 모드 글로벌 상태
  bool _isGlobalMemoMode = false;

  // 실수(오답) 차감 카운트
  int _mistakeCount = 0;

  // 점수 산출 규칙 오버레이 카드 토글 상태
  bool _showScoreOverlay = false;

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

  String get _difficultyEmoji {
    switch (_currentDifficulty) {
      case '초급':
        return '🌱';
      case '중급':
        return '⚡';
      case '고급':
        return '🔥';
      default:
        return '🌱';
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
    _mistakeCount = 0;
    _showScoreOverlay = false;
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
          List<List<int>> tempGrid = _grid.toIntGrid();
          tempGrid[_selectedRow!][_selectedCol!] = 0;
          if (!_engine.isValid(tempGrid, _selectedRow!, _selectedCol!, number)) {
            _mistakeCount++;
          }
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

  int _getCurrentGameScore() {
    int score = _getBaseScore(_currentDifficulty) - _mistakeCount;
    return score < 0 ? 0 : score;
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

    int timeScore;
    if (totalSeconds <= targetSeconds) {
      timeScore = baseScore + (targetSeconds - totalSeconds);
    } else {
      int penalty = totalSeconds - targetSeconds;
      timeScore = baseScore - penalty;
    }

    int score = (timeScore - _mistakeCount) * _difficultyMultiplier;
    return score < 0 ? 0 : score;
  }

  void _checkCompletion() {
    if (_engine.isGridComplete(_grid.toIntGrid())) {
      _timer?.cancel();
      int finalScore = _calculateFinalScore(_elapsedSeconds);
      if (finalScore > _bestScore) {
        _bestScore = finalScore;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: const Color(0xFFFAF8EF),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8EF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFBBADA0), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEE4DA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: Color(0xFFEDC22E),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '축하합니다!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF776E65),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '스도쿠를 성공적으로 완성하셨습니다 🎉',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF776E65),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBADA0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow('난이도', '$_currentDifficulty', Colors.white),
                      const Divider(height: 16, thickness: 1, color: Color(0xFFEEE4DA)),
                      _buildResultRow('경과 시간', _formatDuration(_elapsedSeconds), const Color(0xFFEEE4DA)),
                      const Divider(height: 16, thickness: 1, color: Color(0xFFEEE4DA)),
                      _buildResultRow('최종 점수', '$finalScore점 ⭐', const Color(0xFFEDC22E), isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                      backgroundColor: const Color(0xFF8F7A66),
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
            color: const Color(0xFFEEE4DA),
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
          color: isSelected ? const Color(0xFFEDC22E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : iconColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                level,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : const Color(0xFF776E65),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 16, color: Colors.white),
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
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8EF),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '🐰 ',
              style: TextStyle(fontSize: 22),
            ),
            Text(
              'Chloe Sudoku',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF776E65),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: OutlinedButton.icon(
              onPressed: _startNewGame,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('새 게임'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF776E65),
                side: const BorderSide(color: Color(0xFFBBADA0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBADA0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 1. 난이도 선택 버튼 (이모지 포함)
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
                            color: const Color(0xFFFAF8EF),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              _buildMenuItem('초급', Icons.sentiment_satisfied_alt, const Color(0xFF8F7A66)),
                              _buildMenuItem('중급', Icons.sentiment_neutral, const Color(0xFF8F7A66)),
                              _buildMenuItem('고급', Icons.local_fire_department, const Color(0xFF8F7A66)),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF776E65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _difficultyEmoji,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _currentDifficulty,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down, color: Color(0xFFEEE4DA), size: 18),
                                ],
                              ),
                            ),
                          ),
                          // 2. 실시간 점수 버튼
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showScoreOverlay = !_showScoreOverlay;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF776E65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFEDC22E)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '점수: ${_getCurrentGameScore()}점',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.info_outline, size: 12, color: Color(0xFFEEE4DA)),
                                ],
                              ),
                            ),
                          ),
                          // 3. 경과시간 카드
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF776E65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFF2B179)),
                                const SizedBox(width: 4),
                                Text(
                                  '경과시간: ${_formatDuration(_elapsedSeconds)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showScoreOverlay) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showScoreOverlay = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF776E65),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🏆 최고점수: $_bestScore점',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEDC22E),
                                  ),
                                ),
                                const Icon(Icons.close, size: 16, color: Color(0xFFEEE4DA)),
                              ],
                            ),
                            const Divider(height: 12, thickness: 1, color: Color(0xFF8F7A66)),
                            const Text(
                              '• 초급: 100점 / 3분 (180초)\n'
                              '• 중급: 300점 / 6분 (360초)\n'
                              '• 고급: 600점 / 10분 (600초)\n\n'
                              '⭐ 점수 계산 방식\n'
                              '• 기준 시간 이내 성공: 기본 점수 + (기준 시간 - 해결 시간)\n'
                              '• 기준 시간 초과 성공: 기본 점수 - (해결 시간 - 기준 시간)\n'
                              '• 오답 입력 패널티: 오답 1회당 -1점 감점\n'
                              '• 실패/미완성/새로고침: 0점 처리',
                              style: TextStyle(fontSize: 11, color: Color(0xFFEEE4DA), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Center(
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBADA0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(6),
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
                  const SizedBox(height: 12),
                  // 메모 & 되돌리기 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _onToggleMemoMode,
                            icon: Icon(
                              Icons.edit_note,
                              color: _isGlobalMemoMode ? Colors.white : const Color(0xFF776E65),
                            ),
                            label: Text(
                              '메모',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isGlobalMemoMode ? Colors.white : const Color(0xFF776E65),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isGlobalMemoMode ? const Color(0xFFF2B179) : const Color(0xFFEEE4DA),
                              side: BorderSide(
                                color: _isGlobalMemoMode ? const Color(0xFFF59563) : const Color(0xFFD6CDC4),
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
                              color: _undoHistory.isNotEmpty ? const Color(0xFF776E65) : Colors.grey,
                            ),
                            label: Text(
                              '되돌리기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _undoHistory.isNotEmpty ? const Color(0xFF776E65) : Colors.grey,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFEEE4DA),
                              side: const BorderSide(
                                color: Color(0xFFD6CDC4),
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
            );
          },
        ),
      ),
    );
  }
}
