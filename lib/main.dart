import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'games/2048/2048_screen.dart';

void main() {
  runApp(const ChloeSudokuApp());
}

class ChloeSudokuApp extends StatelessWidget {
  const ChloeSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chloe Sudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/2048': (context) => const Game2048Screen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
