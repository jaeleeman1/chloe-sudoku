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

  void _startNewGame() {
    _timer?.cancel();
    _startTime = DateTime.now();
    _elapsedSeconds = 0;
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--:--';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
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
    });
  }

  void _onNumberSelected(int number) {
    if (_selectedRow != null && _selectedCol != null) {
      setState(() {
        _grid.set(_selectedRow!, _selectedCol!, number);
        _validateGrid();
        _checkCompletion();
      });
    }
  }

  void _onClear() {
    if (_selectedRow != null && _selectedCol != null) {
      setState(() {
        _grid.set(_selectedRow!, _selectedCol!, 0);
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

  void _checkCompletion() {
    if (_engine.isGridComplete(_grid.toIntGrid())) {
      _timer?.cancel();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('축하합니다!'),
          content: Text('스도쿠를 모두 풀었습니다!\n경과 시간: ${_formatDuration(_elapsedSeconds)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame();
              },
              child: const Text('새 게임'),
            ),
          ],
        ),
      );
    }
  }

  bool _isRelated(int r, int c) {
    if (_selectedRow == null || _selectedCol == null) return false;
    if (r == _selectedRow && c == _selectedCol) return false;

    // 좌우 (같은 행) 및 위아래 (같은 열)
    if (r == _selectedRow || c == _selectedCol) return true;

    // 선택한 셀에 입력된 숫자가 있을 경우, 같은 숫자를 가진 다른 셀 강조
    int selectedVal = _grid.get(_selectedRow!, _selectedCol!);
    if (selectedVal != 0 && _grid.get(r, c) == selectedVal) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chloe Sudoku'),
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: '초급', child: Text('초급')),
                      const PopupMenuItem(value: '중급', child: Text('중급')),
                      const PopupMenuItem(value: '고급', child: Text('고급')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentDifficulty,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 18),
                        ],
                      ),
                    ),
                  ),
                  // 시작 시간
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '시작: ${_formatTime(_startTime)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1,
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
          NumberPad(
            onNumberSelected: _onNumberSelected,
            onClear: _onClear,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}