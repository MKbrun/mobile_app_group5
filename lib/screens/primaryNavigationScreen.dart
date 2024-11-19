// primary_navigation_screen.dart
import 'package:flutter/material.dart';
import 'channels.dart';
import 'contacts_screen.dart'; // Add ContactsScreen
import 'calendar_screen.dart';

class PrimaryNavigationScreen extends StatefulWidget {
  const PrimaryNavigationScreen({Key? key}) : super(key: key);

  @override
  State<PrimaryNavigationScreen> createState() =>
      _PrimaryNavigationScreenState();
}

class _PrimaryNavigationScreenState extends State<PrimaryNavigationScreen> {
  int _currentIndex = 0;

  // Updated list of primary screens
  final List<Widget> _screens = [
    const ChannelScreen(),
    const ContactsScreen(), // Replaced ChatScreen with ContactsScreen
    const CalendarScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
