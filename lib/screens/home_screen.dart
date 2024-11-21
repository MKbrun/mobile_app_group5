// home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app_group5/screens/primaryNavigationScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrimaryNavigationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondary, // Use theme color
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(30),
              ),
              child: const Icon(Icons.arrow_forward,
                  size: 30, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
