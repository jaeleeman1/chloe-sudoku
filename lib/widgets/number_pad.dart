import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onClear;
  final Set<int> completedNumbers;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    required this.onClear,
    this.completedNumbers = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) => _buildNumberButton(index + 1)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...List.generate(4, (index) => _buildNumberButton(index + 6)),
            _buildClearButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    bool isCompleted = completedNumbers.contains(number);

    return ElevatedButton(
      onPressed: () => onNumberSelected(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted ? Colors.amber.shade300 : Colors.blue.shade50,
        foregroundColor: isCompleted ? Colors.brown.shade900 : Colors.blue.shade900,
        minimumSize: const Size(50, 50),
        elevation: isCompleted ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isCompleted ? Colors.amber.shade600 : Colors.blue.shade200,
            width: isCompleted ? 1.8 : 1.0,
          ),
        ),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 20,
          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: onClear,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[100],
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Icon(Icons.backspace_outlined, color: Colors.orange),
    );
  }
}
