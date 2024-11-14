// shift_management_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class ShiftManagementScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ShiftManagementScreen({super.key, required this.selectedDate});

  @override
  _ShiftManagementScreenState createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  late DateTime _selectedDate;
  final DateFormat _dateFormatter = DateFormat('MM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  // Method to open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for shifts
    final List<Map<String, dynamic>> shifts = [
      {"time": "08:00 - 12:00", "available": true, "user": "Alice"},
      {"time": "12:00 - 16:00", "available": false, "user": "Bob"},
      {"time": "16:00 - 20:00", "available": true, "user": "Charlie"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift Management"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Date",
                    hintText: "mm/dd/yyyy",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Use theme color
                      ),
                    ),
                  ),
                  controller: TextEditingController(
                    text: _dateFormatter.format(_selectedDate),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shifts.length,
              itemBuilder: (context, index) {
                final shift = shifts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      shift["time"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Assigned to: ${shift["user"]}"),
                    trailing: shift["available"]
                        ? ElevatedButton(
                            onPressed: () {
                              // Dummy action for "Take Shift"
                            },
                            style: AppTheme
                                .lightGreenButtonStyle, // Light green button
                            child: const Text("Take Shift"),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              // Dummy action for "Trade Shift"
                            },
                            child: const Text(
                                "Trade Shift"), // Blue button by default
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
