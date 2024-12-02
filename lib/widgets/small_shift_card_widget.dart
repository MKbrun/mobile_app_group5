import 'package:flutter/material.dart';

class SmallShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;

  const SmallShiftCardWidget({
    Key? key,
    required this.shift,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime? shiftDate = shift['date'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        title: Text(
          shiftDate != null
              ? "${shiftDate.day}-${shiftDate.month}-${shiftDate.year}"
              : "No Date Provided",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          shift['title'] ?? "No Title",
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
