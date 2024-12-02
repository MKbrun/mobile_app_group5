import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/primaryNavigationScreen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>> _getCurrentUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return {
        'username': '[[DEV]]',
        'image_url': null,
      };
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      return {
        'username': userDoc.data()?['username'] ?? '[[DEV]]',
        'image_url': userDoc.data()?['image_url'],
      };
    } else {
      return {
        'username': '[[DEV]]',
        'image_url': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching user data'),
            );
          }

          final userData = snapshot.data!;
          final username = userData['username'];
          final imageUrl = userData['image_url'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                ),
                const SizedBox(height: 20),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PrimaryNavigationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme
                        .blueColor, // Use AppTheme.blueColor for consistency
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(30),
                  ),
                  child: const Icon(Icons.arrow_forward,
                      size: 30, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
