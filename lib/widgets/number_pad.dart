import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final VoidCallback onClear;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    required this.onClear,
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
    return ElevatedButton(
      onPressed: () => onNumberSelected(number),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('$number', style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: onClear,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[100],
        minimumSize: const Size(50, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.backspace_outlined, color: Colors.orange),
    );
  }
}
