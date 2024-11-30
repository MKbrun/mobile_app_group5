import 'package:flutter/material.dart';
import './channel/channels.dart';
import 'contacts_screen.dart';
import 'calendar_screen.dart';
import 'shift_management_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class PrimaryNavigationScreen extends StatefulWidget {
  const PrimaryNavigationScreen({super.key});

  @override
  State<PrimaryNavigationScreen> createState() =>
      _PrimaryNavigationScreenState();
}

class _PrimaryNavigationScreenState extends State<PrimaryNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isPopupOpen = false; // Track if the popup menu is open
  int _selectedNavItem = 0; // Track selected navigation item
  final GlobalKey _multiPurposeButtonKey =
      GlobalKey(); // GlobalKey for 3-dot button

  late OverlayEntry _overlayEntry;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  final List<Widget> _screens = [
    const ContactsScreen(),
    const ChannelScreen(),
    const CalendarScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a quicker duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100), // Adjusted duration
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom
      end: Offset.zero, // End at original position
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isPopupOpen = false; // Close popup if open
      _selectedNavItem = index;
    });
  }

  Widget _divider() {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
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
              icon: Icons.contacts,
              label: 'Contacts',
              index: 1,
            ),
            _divider(),
            _buildNavItem(
              context,
              icon: Icons.layers,
              label: 'Channels',
              index: 0,
            ),
            _divider(),
            // Multi-purpose button
            _buildPopupMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required IconData icon, required String label, required int index}) {
    final bool isSelected = _selectedNavItem == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.darkBlueColor : AppTheme.blueColor,
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

  Widget _buildPopupMenuButton() {
    return Expanded(
      child: GestureDetector(
        key: _multiPurposeButtonKey, // Attach GlobalKey here
        onTap: () {
          setState(() {
            _isPopupOpen = true;
            _selectedNavItem = 3; // Set selected nav item to 3-dot button
          });
          _showCustomMenu();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _selectedNavItem == 3
                ? AppTheme.darkBlueColor
                : AppTheme.blueColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomMenu() {
    final RenderBox button =
        _multiPurposeButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final Size buttonSize = button.size;

    final double extraMargin = 50.0;

    // Calculate the position so that the menu appears just above the button
    final Offset menuPosition = Offset(
      buttonPosition.dx,
      buttonPosition.dy - extraMargin,
    );

    _overlayEntry = _createOverlayEntry(menuPosition, buttonSize.width);

    Overlay.of(context).insert(_overlayEntry);
    _animationController.forward();
  }

  OverlayEntry _createOverlayEntry(Offset position, double width) {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          // Dismiss the popup when tapping outside
          _animationController.reverse().then((value) {
            _overlayEntry.remove();
            setState(() {
              _isPopupOpen = false;
              _selectedNavItem = -1;
            });
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy - 100, // Adjusted to position above the button
                width: width,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPopupMenuItem(
                        icon: Icons.calendar_today,
                        label: 'Calendar',
                        onTap: () {
                          _animationController.reverse().then((value) {
                            _overlayEntry.remove();
                            setState(() {
                              _currentIndex = 2; // CalendarScreen index
                              _selectedNavItem = 2; // Highlight Calendar
                              _isPopupOpen = false;
                            });
                          });
                        },
                      ),
                      _buildPopupMenuItem(
                        icon: Icons.schedule,
                        label: 'Shift Management',
                        onTap: () {
                          _animationController.reverse().then((value) {
                            _overlayEntry.remove();
                            setState(() {
                              _selectedNavItem = -1;
                              _isPopupOpen = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShiftManagementScreen(
                                  selectedDate: DateTime.now(),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenuItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        color: AppTheme.blueColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
