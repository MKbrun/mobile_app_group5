import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class SwapRequestButton extends StatelessWidget {
  final bool isAvailable;
  final String assignedUserId;
  final String currentUserId;
  final VoidCallback onTakeShift;
  final VoidCallback onSwapShift;

  const SwapRequestButton({
    Key? key,
    required this.isAvailable,
    required this.assignedUserId,
    required this.currentUserId,
    required this.onTakeShift,
    required this.onSwapShift,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      buttonAction = onSwapShift;
      buttonColor = AppTheme.blueColor;
    }

    return ElevatedButton(
      onPressed: buttonAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
      ),
      child: Text(buttonText),
    );
  }
}
