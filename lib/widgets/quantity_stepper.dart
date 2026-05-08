import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDec = value > minValue;
    final canInc = value < maxValue;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDec ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
            color: theme.colorScheme.primary,
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: canInc ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
            color: theme.colorScheme.primary,
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
