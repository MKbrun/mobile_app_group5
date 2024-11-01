import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  @override
Widget build(BuildContext context) {
  return SizedBox(
    height: kBottomNavigationBarHeight * 1.5,
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Private Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.layers_outlined),
          label: 'Servers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Calendar',
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}
}
