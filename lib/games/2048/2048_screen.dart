import 'package:flutter/material.dart';
import '2048_game.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late Game2048 _game;
  late List<List<int>> _board;

  @override
  void initState() {
    super.initState();
    _game = Game2048();
    _board = _game.board;
  }

  void _handleSwipe(DragEndDetails details) {
    Direction direction;
    
    // Determine swipe direction based on velocity
    if (details.velocity.pixelsPerSecond.dx > 0) {
      direction = Direction.right;
    } else if (details.velocity.pixelsPerSecond.dx < 0) {
      direction = Direction.left;
    } else if (details.velocity.pixelsPerSecond.dy > 0) {
      direction = Direction.down;
    } else {
      direction = Direction.up;
    }

    _moveTiles(direction);
  }

  void _moveTiles(Direction direction) {
    setState(() {
      bool moved = _game.move(direction);
      _board = _game.board;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Game'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onPanEnd: _handleSwipe,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreCard('Score', _game.score.toString()),
                  _buildScoreCard('Best', '1280'),
                ],
              ),
              const SizedBox(height: 20),
              
              // Game board
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    int row = index ~/ 4;
                    int col = index % 4;
                    int value = _board[row][col];
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: _getTileColor(value),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Center(
                        child: value != 0
                            ? Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              )
                            : Container(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Game controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _game.resetGame();
                        _board = _game.board;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Game over or win message
              if (_game.gameOver)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                )
              else if (_game.won)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'You Win!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.blue.shade100;
      case 2:
        return Colors.blue.shade50;
      case 4:
        return Colors.blue.shade100;
      case 8:
        return Colors.orange.shade300;
      case 16:
        return Colors.orange.shade400;
      case 32:
        return Colors.orange.shade500;
      case 64:
        return Colors.orange.shade600;
      case 128:
        return Colors.purple.shade400;
      case 256:
        return Colors.purple.shade500;
      case 512:
        return Colors.purple.shade600;
      case 1024:
        return Colors.purple.shade700;
      case 2048:
        return Colors.purple.shade800;
      default:
        return Colors.purple.shade900;
    }
  }
}