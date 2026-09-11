import 'dart:math';
import 'package:flutter/material.dart';

class Game2048 {
  static const int BOARD_SIZE = 4;
  late List<List<int>> _board;
  int _score = 0;
  bool _gameOver = false;
  bool _won = false;

  Game2048() {
    resetGame();
  }

  void resetGame() {
    _board = List.generate(BOARD_SIZE, (index) => List.filled(BOARD_SIZE, 0));
    _score = 0;
    _gameOver = false;
    _won = false;
    addRandomTile();
    addRandomTile();
  }

  List<List<int>> get board => _board;

  int get score => _score;

  bool get gameOver => _gameOver;

  bool get won => _won;

  void addRandomTile() {
    List<List<int>> emptyCells = [];
    for (int i = 0; i < BOARD_SIZE; i++) {
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (_board[i][j] == 0) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      Random random = Random();
      List<int> cell = emptyCells[random.nextInt(emptyCells.length)];
      _board[cell[0]][cell[1]] = random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  bool move(Direction direction) {
    if (_gameOver) return false;

    List<List<int>> originalBoard = deepCopy(_board);
    bool moved = false;

    switch (direction) {
      case Direction.up:
        moved = moveUp();
        break;
      case Direction.down:
        moved = moveDown();
        break;
      case Direction.left:
        moved = moveLeft();
        break;
      case Direction.right:
        moved = moveRight();
        break;
    }

    if (moved) {
      addRandomTile();
      checkGameOver();
      checkWin();
    }

    return moved;
  }

  bool moveUp() {
    bool moved = false;
    for (int col = 0; col < BOARD_SIZE; col++) {
      List<int> column = [];
      for (int row = 0; row < BOARD_SIZE; row++) {
        if (_board[row][col] != 0) {
          column.add(_board[row][col]);
        }
      }

      // Merge tiles
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2;
          _score += column[i];
          column.removeAt(i + 1);
        }
      }

      // Update board
      for (int row = 0; row < BOARD_SIZE; row++) {
        int newValue = row < column.length ? column[row] : 0;
        if (_board[row][col] != newValue) {
          moved = true;
        }
        _board[row][col] = newValue;
      }
    }

    return moved;
  }

  bool moveDown() {
    bool moved = false;
    for (int col = 0; col < BOARD_SIZE; col++) {
      List<int> column = [];
      for (int row = BOARD_SIZE - 1; row >= 0; row--) {
        if (_board[row][col] != 0) {
          column.add(_board[row][col]);
        }
      }

      // Merge tiles
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2;
          _score += column[i];
          column.removeAt(i + 1);
        }
      }

      // Update board
      for (int row = BOARD_SIZE - 1; row >= 0; row--) {
        int newValue = row >= BOARD_SIZE - column.length ? column[BOARD_SIZE - 1 - row] : 0;
        if (_board[row][col] != newValue) {
          moved = true;
        }
        _board[row][col] = newValue;
      }
    }

    return moved;
  }

  bool moveLeft() {
    bool moved = false;
    for (int row = 0; row < BOARD_SIZE; row++) {
      List<int> rowTiles = [];
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (_board[row][col] != 0) {
          rowTiles.add(_board[row][col]);
        }
      }

      // Merge tiles
      for (int i = 0; i < rowTiles.length - 1; i++) {
        if (rowTiles[i] == rowTiles[i + 1]) {
          rowTiles[i] *= 2;
          _score += rowTiles[i];
          rowTiles.removeAt(i + 1);
        }
      }

      // Update board
      for (int col = 0; col < BOARD_SIZE; col++) {
        int newValue = col < rowTiles.length ? rowTiles[col] : 0;
        if (_board[row][col] != newValue) {
          moved = true;
        }
        _board[row][col] = newValue;
      }
    }

    return moved;
  }

  bool moveRight() {
    bool moved = false;
    for (int row = 0; row < BOARD_SIZE; row++) {
      List<int> rowTiles = [];
      for (int col = BOARD_SIZE - 1; col >= 0; col--) {
        if (_board[row][col] != 0) {
          rowTiles.add(_board[row][col]);
        }
      }

      // Merge tiles
      for (int i = 0; i < rowTiles.length - 1; i++) {
        if (rowTiles[i] == rowTiles[i + 1]) {
          rowTiles[i] *= 2;
          _score += rowTiles[i];
          rowTiles.removeAt(i + 1);
        }
      }

      // Update board
      for (int col = BOARD_SIZE - 1; col >= 0; col--) {
        int newValue = col >= BOARD_SIZE - rowTiles.length ? rowTiles[BOARD_SIZE - 1 - col] : 0;
        if (_board[row][col] != newValue) {
          moved = true;
        }
        _board[row][col] = newValue;
      }
    }

    return moved;
  }

  void checkGameOver() {
    // Check if there are empty cells
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (_board[row][col] == 0) {
          return;
        }
      }
    }

    // Check if there are adjacent tiles with same value
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        int current = _board[row][col];
        if ((row < BOARD_SIZE - 1 && _board[row + 1][col] == current) ||
            (col < BOARD_SIZE - 1 && _board[row][col + 1] == current)) {
          return;
        }
      }
    }

    _gameOver = true;
  }

  void checkWin() {
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (_board[row][col] == 2048) {
          _won = true;
          return;
        }
      }
    }
  }

  List<List<int>> deepCopy(List<List<int>> source) {
    return source.map((row) => List<int>.from(row)).toList();
  }
}

enum Direction { up, down, left, right }