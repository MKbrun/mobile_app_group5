import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'settings_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';
import 'package:mobile_app_group5/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _getCurrentUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return {
        'username': '[[DEV]]',
        'email': 'Not Available',
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
        'email': userDoc.data()?['email'] ?? 'Not Available',
        'image_url': userDoc.data()?['image_url'],
      };
    } else {
      return {
        'username': '[[DEV]]',
        'email': 'Not Available',
        'image_url': null,
      };
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.blueColor,
        elevation: 0,
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
          final email = userData['email'];
          final imageUrl = userData['image_url'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Theme.of(context).appBarTheme.backgroundColor,
                        backgroundImage:
                            imageUrl != null ? NetworkImage(imageUrl) : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          MyApp.of(context)?.setThemeMode(
                            isDarkMode ? ThemeMode.light : ThemeMode.dark,
                          );

                          RestartableApp.restartApp(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.blueColor, // Set color from AppTheme
                          foregroundColor:
                              Colors.white, // Ensure the text color is readable
                          fixedSize: const Size(
                              200, 50), // Optional: size for consistency
                        ),
                        child: Text(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.redColor
                              .withOpacity(0.9), // Use AppTheme redColor
                          fixedSize: const Size(150, 50),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
