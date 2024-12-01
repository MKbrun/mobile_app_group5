import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;
  final VoidCallback onTakeShift;
  final String? currentUserId;

  const ShiftCardWidget({
    Key? key,
    required this.shift,
    required this.onTakeShift,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assignedUsername = shift['assignedUsername'] ?? 'Unassigned';
    String assignedUserId = shift['assignedUserId'] ?? '';
    bool isAvailable = assignedUserId.isEmpty;

    String buttonText;
    VoidCallback? buttonAction;
    Color buttonColor;

    if (isAvailable) {
      buttonText = "Take Shift";
      buttonAction = onTakeShift;
      buttonColor = AppTheme.lightGreenColor;
    } else if (assignedUserId == currentUserId) {
      buttonText = "Assigned";
      buttonAction = null;
      buttonColor = Colors.grey;
    } else {
      buttonText = "Swap";
      buttonAction = () {
        // Implement swap logic later here
      };
      buttonColor = AppTheme.blueColor;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          shift["startTime"] != null && shift["endTime"] != null
              ? "${shift['startTime'].hour}:${shift['startTime'].minute.toString().padLeft(2, '0')} - ${shift['endTime'].hour}:${shift['endTime'].minute.toString().padLeft(2, '0')}"
              : "No Time Provided",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Assigned to: $assignedUsername",
        ),
        trailing: ElevatedButton(
          onPressed: buttonAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }
}
