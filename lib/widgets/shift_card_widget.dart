import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;
  final VoidCallback onTakeShift;
  final VoidCallback onSwapShift;
  final VoidCallback onApproveSwap;
  final String? currentUserId;

  const ShiftCardWidget({
    Key? key,
    required this.shift,
    required this.onTakeShift,
    required this.onSwapShift,
    required this.onApproveSwap,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assignedUsername = shift['assignedUsername'] ?? 'Unassigned';
    String assignedUserId = shift['assignedUserId'] ?? '';
    bool isAvailable = assignedUserId.isEmpty;
    bool isSwapRequestedByCurrentUser =
        shift['tradeRequestedBy'] == currentUserId &&
            shift['tradeTargetUserId'] != '';
    bool isSwapRequestedForCurrentUser =
        shift['tradeTargetUserId'] == currentUserId &&
            shift['tradeRequestedBy'] != '';

    // Determine button properties
    String buttonText;
    VoidCallback? buttonAction;
    Color buttonColor;

    if (isSwapRequestedForCurrentUser) {
      buttonText = "Swap Request";
      buttonAction = onApproveSwap;
      buttonColor = AppTheme.blueColor;
    } else if (isSwapRequestedByCurrentUser) {
      buttonText = "Request Sent";
      buttonAction = null;
      buttonColor = Colors.grey;
    } else if (isAvailable) {
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

    // Extract start and end time
    String startTime = shift['startTime'] != null
        ? "${shift['startTime'].hour.toString().padLeft(2, '0')}:${shift['startTime'].minute.toString().padLeft(2, '0')}"
        : "--:--";
    String endTime = shift['endTime'] != null
        ? "${shift['endTime'].hour.toString().padLeft(2, '0')}:${shift['endTime'].minute.toString().padLeft(2, '0')}"
        : "--:--";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Widget
          CircleAvatar(
            radius: 25,
            backgroundImage: isAvailable
                ? AssetImage(
                    'assets/images/default_avatar.png') // Replace with your default avatar
                : NetworkImage(shift['avatarUrl'] ?? '') as ImageProvider,
            backgroundColor: Colors.grey[200], // For when there's no image
          ),
          const SizedBox(width: 16), // Space between avatar and text

          // Column with Start and End Time and Username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the shift start and end time
                Text(
                  "$startTime - $endTime",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Display assigned username
                Text(
                  "Assigned to: $assignedUsername",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ],
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: buttonAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
