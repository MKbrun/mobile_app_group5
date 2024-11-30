// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_group5/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/auth.dart';
import 'package:mobile_app_group5/screens/home_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart'; // Import the theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: AppTheme.lightTheme, // Apply the theme from the theme file
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading screen if waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If user data exists, show home screen
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Otherwise, show login screen
          return const AuthScreen(); // Replace with LoginScreen if available
        },
      ),
    );
  }
}
