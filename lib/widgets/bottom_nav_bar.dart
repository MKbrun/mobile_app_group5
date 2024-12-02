// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

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
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.chat_bubble_outline,
            label: 'Private Chat',
            index: 0,
          ),
          _divider(),
          _buildNavItem(
            context,
            icon: Icons.layers_outlined,
            label: 'Servers',
            index: 1,
          ),
          _divider(),
          _buildNavItem(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Calendar',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String label, required int index}) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(
                    255, 60, 95, 128) // Darker blue for selected
                : AppTheme.blueColor,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                        .withOpacity(0.85) // Slightly darker white for selected
                    : Colors.white,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 0.75,
      height: 35,
      color: Colors.white,
    );
  }
}
