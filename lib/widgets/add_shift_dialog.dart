import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddShiftDialog extends StatefulWidget {
  @override
  _AddShiftDialogState createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedUser = "Unassigned";

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
      title: const Text("Add New Shift"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start Time Picker
          ListTile(
            title: const Text("Start Time"),
            trailing: Text(
              _formatTimeOfDay(startTime),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () => _showCupertinoTimePicker(context, true),
          ),
          // End Time Picker
          ListTile(
            title: const Text("End Time"),
            trailing: Text(
              _formatTimeOfDay(endTime),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () => _showCupertinoTimePicker(context, false),
          ),
          // Dropdown for Assigning User (Not pressable now, just for display)
          DropdownButton<String>(
            value: selectedUser,
            items: <String>['Unassigned', 'Alice', 'Bob', 'Charlie']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: null, // Disable interaction for now
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text("Add Shift"),
          onPressed: () {
            if (startTime != null && endTime != null) {
              // Calculate duration
              final startInMinutes = startTime!.hour * 60 + startTime!.minute;
              final endInMinutes = endTime!.hour * 60 + endTime!.minute;
              final durationInHours =
                  ((endInMinutes - startInMinutes) / 60).toStringAsFixed(1);

              // Create new shift data
              Map<String, dynamic> newShift = {
                "time":
                    "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)} (${durationInHours} hrs)",
                "available": true,
                "user": selectedUser,
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
        ),
      ],
    );
  }
}
