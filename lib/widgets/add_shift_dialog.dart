import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class AddShiftDialog extends StatefulWidget {
  const AddShiftDialog({super.key});

  @override
  _AddShiftDialogState createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedUser = "Unassigned";
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch users from Firestore and handle missing fields
  void _fetchUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return {
            "id": doc.id,
            "username": data != null && data.containsKey('username')
                ? data['username']
                : 'Unknown',
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  // Function to format TimeOfDay to 24-hour HH:mm format
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "Select";
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showCupertinoTimePicker(
      BuildContext context, bool isStartTime) async {
    int selectedHour =
        isStartTime ? (startTime?.hour ?? 0) : (endTime?.hour ?? 0);
    int selectedMinute =
        isStartTime ? (startTime?.minute ?? 0) : (endTime?.minute ?? 0);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isStartTime ? "Select Start Time" : "Select End Time",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Hour Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedHour,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedHour = index;
                          });
                        },
                        children: List<Widget>.generate(24, (int index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Minute Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinute,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedMinute = index;
                          });
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              // Confirm Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isStartTime) {
                        startTime = TimeOfDay(
                            hour: selectedHour, minute: selectedMinute);
                      } else {
                        endTime = TimeOfDay(
                            hour: selectedHour, minute: selectedMinute);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blueColor,
                  ),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(16),
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        "Add New Shift",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shift Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Shift Title",
              labelStyle:
                  TextStyle(color: AppTheme.blueColor), // Apply theme color
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.blueColor),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.blueColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Start Time Picker
          ListTile(
            title: Text(
              "Start Time",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Text(
              _formatTimeOfDay(startTime),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () => _showCupertinoTimePicker(context, true),
          ),
          // End Time Picker
          ListTile(
            title: Text(
              "End Time",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Text(
              _formatTimeOfDay(endTime),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () => _showCupertinoTimePicker(context, false),
          ),
          // Dropdown for Assigning User
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor:
                  Colors.white, // Forces the dropdown background to be white
            ),
            child: DropdownButton<String>(
              value: selectedUser,
              items: [
                const DropdownMenuItem<String>(
                  value: "Unassigned",
                  child: Text("Unassigned"),
                ),
                ...users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user["id"],
                    child: Text(user["username"]),
                  );
                }),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedUser = newValue ?? "Unassigned";
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.blueColor, // Update "Cancel" button color
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (startTime != null && endTime != null) {
              // Create DateTime objects that include the selected date and time for the shift.
              DateTime selectedDate = DateTime
                  .now(); // Update this to receive the selected date appropriately
              DateTime startDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                startTime!.hour,
                startTime!.minute,
              );

              DateTime endDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                endTime!.hour,
                endTime!.minute,
              );

              // Create new shift data
              Map<String, dynamic> newShift = {
                "date": Timestamp.fromDate(selectedDate),
                "startTime": Timestamp.fromDate(startDateTime),
                "endTime": Timestamp.fromDate(endDateTime),
                "assignedUserId":
                    selectedUser == "Unassigned" ? "" : selectedUser,
                "title": _titleController.text.trim(),
              };
              Navigator.of(context).pop(newShift);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select start and end times."),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppTheme.blueColor, // Update "Add Shift" button color
          ),
          child: const Text("Add Shift"),
        ),
      ],
    );
  }
}
