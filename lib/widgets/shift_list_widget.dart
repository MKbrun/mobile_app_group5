import 'package:flutter/material.dart';
import 'shift_card_widget.dart';

class ShiftListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> shifts;
  final Function(int) onTakeShift;

  const ShiftListWidget({
    super.key,
    required this.shifts,
    required this.onTakeShift,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        return ShiftCardWidget(
          shift: shifts[index],
          onTakeShift: () => onTakeShift(index),
        );
      },
    );
  }
}
