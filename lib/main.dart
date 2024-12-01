import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app_group5/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_group5/screens/auth.dart';
import 'package:mobile_app_group5/screens/home_screen.dart';
import 'package:mobile_app_group5/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(RestartableApp(child: const MyApp()));
}

class RestartableApp extends StatefulWidget {
  final Widget child;

  const RestartableApp({required this.child});

  static void restartApp(BuildContext context) {
    final _RestartableAppState? state =
        context.findAncestorStateOfType<_RestartableAppState>();
    state?.restartApp();
  }

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  Key _key = UniqueKey(); 

  void restartApp() {
    setState(() {
      _key = UniqueKey(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); 
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _saveThemeMode(mode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return AuthScreen();
        },
      ),
    );
  }
}
