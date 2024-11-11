import 'package:flutter/material.dart';
import 'package:mobile_app_group5/screens/channels.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              // Dummy image
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 20),
            Text(
              'User Name', // Dummy avatar
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Dummy nav to ChannelScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChannelScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(30),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Icon(Icons.arrow_forward, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
