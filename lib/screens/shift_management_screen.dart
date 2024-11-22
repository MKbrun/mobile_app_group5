import 'package:flutter/material.dart';
import 'package:mobile_app_group5/widgets/add_shift_dialog.dart';
import 'package:mobile_app_group5/widgets/shift_list_widget.dart';
import 'package:mobile_app_group5/widgets/date_picker_widget.dart';

class ShiftManagementScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ShiftManagementScreen({super.key, required this.selectedDate});

  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  late DateTime _selectedDate;
  bool _isAdmin = true; // Hardcoded variable to simulate admin or user roles

  // Dummy data for shifts
  List<Map<String, dynamic>> shifts = [
    {"time": "08:00 - 12:00", "available": true, "user": "Alice"},
    {"time": "12:00 - 16:00", "available": false, "user": "Bob"},
    {"time": "16:00 - 20:00", "available": true, "user": "Charlie"},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  void _addShift(Map<String, dynamic> newShift) {
    setState(() {
      shifts.add(newShift);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift Management"),
      ),
      body: Column(
        children: [
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDatePicked: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic>? newShift = await showDialog(
                    context: context,
                    builder: (context) => AddShiftDialog(),
                  );
                  if (newShift != null) {
                    _addShift(newShift);
                  }
                },
                child: const Text("Add New Shift"),
              ),
            ),
          Expanded(
            child: ShiftListWidget(
              shifts: shifts,
              onTakeShift: (index) {
                setState(() {
                  shifts[index]["user"] = "Current User";
                  shifts[index]["available"] = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
