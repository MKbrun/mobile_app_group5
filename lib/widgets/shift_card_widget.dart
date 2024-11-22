import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;
  final VoidCallback onTakeShift;

  const ShiftCardWidget({
    super.key,
    required this.shift,
    required this.onTakeShift,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          shift["time"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Assigned to: ${shift["user"]}"),
        trailing: shift["available"]
            ? ElevatedButton(
                onPressed: onTakeShift,
                style: AppTheme.lightGreenButtonStyle,
                child: const Text("Take Shift"),
              )
            : const Text("Assigned"),
      ),
    );
  }
}
