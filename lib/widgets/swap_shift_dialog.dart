import 'package:flutter/material.dart';

class SwapShiftDialog extends StatelessWidget {
  final List<Map<String, dynamic>> userShifts;

  const SwapShiftDialog({Key? key, required this.userShifts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select a Shift to Swap"),
      content: SingleChildScrollView(
        child: Column(
          children: userShifts.map((shift) {
            return ListTile(
              title: Text(
                "${shift['startTime'].hour}:${shift['startTime'].minute.toString().padLeft(2, '0')} - ${shift['endTime'].hour}:${shift['endTime'].minute.toString().padLeft(2, '0')}",
              ),
              onTap: () {
                Navigator.of(context).pop(shift); // Return the selected shift
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
