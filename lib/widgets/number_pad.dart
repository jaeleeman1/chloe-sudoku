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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _buildNumberButton(context, index + 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ...List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: _buildNumberButton(context, index + 6),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _buildClearButton(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, int number) {
    bool isCompleted = completedNumbers.contains(number);

    return AspectRatio(
      aspectRatio: 1.25,
      child: ElevatedButton(
        onPressed: () => onNumberSelected(number),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isCompleted ? const Color(0xFFEDC22E) : const Color(0xFFEEE4DA),
          foregroundColor: isCompleted ? Colors.white : const Color(0xFF776E65),
          elevation: isCompleted ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isCompleted ? const Color(0xFFEDC53F) : const Color(0xFFD6CDC4),
              width: isCompleted ? 1.5 : 1.0,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: ElevatedButton(
        onPressed: onClear,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF2B179),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFF59563), width: 1.0),
          ),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(Icons.backspace_outlined, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
