import 'package:flutter/material.dart';
import 'package:mobile_app_group5/widgets/bottom_nav_bar.dart';

//Screen to show the app is loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

@override
  State<StatefulWidget> createState() {
    return _SplashScreenState();
  }
}


class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;

  void _onNavBarTap (int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/loading.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 10),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onTap: _onNavBarTap,
        currentIndex: _currentIndex,
      ),
    );
  }
}
