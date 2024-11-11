import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_group5/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/calendar_screen.dart';

import 'package:mobile_app_group5/screens/channels.dart';

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
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 13, 61, 94)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //Checks if firebase is waiting on data and shows a loading screen instead of placeholder
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ChannelScreen();
          }

          //If there is userdata already stored on the device, the app will take you past the login screen
          if (snapshot.hasData) {
            return const CalendarScreen(); //Må endres til "main skjerm" typ
          }

          //If no userdata is stored it will take you to login screen
          return const CalendarScreen();
        },
      ),
    );
  }
}
