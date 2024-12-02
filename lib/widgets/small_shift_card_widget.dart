import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class SmallShiftCardWidget extends StatelessWidget {
  final Map<String, dynamic> shift;
  final String currentUserId;

  const SmallShiftCardWidget({
    super.key,
    required this.shift,
    required this.currentUserId,
  });

  Future<String> _fetchAssignedUsername(String assignedUserId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(assignedUserId)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['username'] ?? 'Unknown User';
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    String assignedUserId = shift['assignedUserId'] ?? '';

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
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (shift['image_url'] != null && shift['image_url'].isNotEmpty)
                    ? NetworkImage(shift['image_url'])
                    : null,
            child: (shift['image_url'] == null || shift['image_url'].isEmpty)
                ? Text(
                    assignedUserId.isNotEmpty
                        ? assignedUserId[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
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
                // Display assigned username only when it is fetched
                if (assignedUserId.isNotEmpty)
                  FutureBuilder<String>(
                    future: _fetchAssignedUsername(assignedUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Text(
                          "Assigned to: ${snapshot.data}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done &&
                          snapshot.hasError) {
                        return Text(
                          "Assigned to: Unknown User",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        );
                      } else {
                        return SizedBox
                            .shrink(); // Hide the text until it's loaded
                      }
                    },
                  ),
                if (assignedUserId.isEmpty)
                  Text(
                    "Assigned to: Unassigned",
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
