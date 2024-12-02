import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class SmallShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;
  final String currentUserId;

  const SmallShiftCardWidget({
    Key? key,
    required this.shift,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String assignedUsername = shift['assignedUsername'] ?? 'Unassigned';

    // Extract start and end time
    String startTime = shift['startTime'] != null
        ? "${shift['startTime'].hour.toString().padLeft(2, '0')}:${shift['startTime'].minute.toString().padLeft(2, '0')}"
        : "--:--";
    String endTime = shift['endTime'] != null
        ? "${shift['endTime'].hour.toString().padLeft(2, '0')}:${shift['endTime'].minute.toString().padLeft(2, '0')}"
        : "--:--";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Widget
          CircleAvatar(
            radius: 25, // Slightly increased radius
            backgroundImage: shift['assignedUserId'] == ''
                ? AssetImage('assets/images/default_avatar.png')
                : NetworkImage(shift['avatarUrl'] ?? '') as ImageProvider,
            backgroundColor: Colors.grey[200], // For when there's no image
          ),
          const SizedBox(width: 16), // Increased space between avatar and text

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
        ],
      ),
    );
  }
}
