import 'package:flutter/material.dart';
import 'channels.dart';
import 'contacts_screen.dart';
import 'calendar_screen.dart';

class PrimaryNavigationScreen extends StatefulWidget {
  const PrimaryNavigationScreen({Key? key}) : super(key: key);

  @override
  State<PrimaryNavigationScreen> createState() =>
      _PrimaryNavigationScreenState();
}

class _PrimaryNavigationScreenState extends State<PrimaryNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChannelScreen(),
    const ContactsScreen(),
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
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width, // Full width
        height: 70, // Fixed height for the navigation bar
        decoration: const BoxDecoration(
          color: Colors.white, // Background color
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5), // Top border
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Match full height
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context,
              icon: Icons.layers,
              label: 'Channels',
              index: 0,
            ),
            _divider(),
            _buildNavItem(
              context,
              icon: Icons.contacts,
              label: 'Contacts',
              index: 1,
            ),
            _divider(),
            _buildNavItem(
              context,
              icon: Icons.calendar_today,
              label: 'Calendar',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3C5F80) // Darker blue for selected
                : const Color(0xFF7097BC), // Light blue for unselected
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: double.infinity, // Match parent height
      color: Colors.white.withOpacity(0.6), // Divider color
    );
  }
}
