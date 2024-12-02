import 'package:flutter/material.dart';

class AppTheme {
  // Static Colors
  static const Color blueColor = Color.fromARGB(255, 46, 112, 174);
  static const Color lightGreenColor = Color(0xFFA6CF98);
  static const Color darkBlueColor = Color.fromARGB(255, 81, 125, 167);
  static Color redColor = Colors.red.withOpacity(0.9);
  static const Color White = Color.fromARGB(255, 242, 244, 247);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 242, 244, 247),
    scaffoldBackgroundColor: const Color.fromARGB(255, 242, 244, 247),
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 242, 244, 247),
      secondary: blueColor,
      tertiary: const Color.fromARGB(255, 255, 255, 255),
      tertiaryContainer: Color.fromARGB(255, 245, 245, 245),
      surface: Color.fromARGB(255, 158, 158, 158),
      onPrimary: Colors.black, // Explicitly set black for light mode
      onSurface: const Color.fromARGB(255, 75, 74, 74),
    ),
    appBarTheme: _lightAppBarTheme,
    textTheme: _lightTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    bottomNavigationBarTheme: _lightBottomNavigationBarTheme,
    inputDecorationTheme: _lightInputDecorationTheme,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 48, 48, 48),
    scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
    colorScheme: ColorScheme.dark(
      primary: const Color.fromARGB(255, 33, 33, 33),
      secondary: darkBlueColor,
      tertiary: const Color.fromARGB(255, 0, 0, 0),
      tertiaryContainer: Color.fromARGB(255, 30, 30, 30),
      surface: Color.fromARGB(255, 33, 33, 33),
      onPrimary: Colors.white, // Explicitly set white for dark mode
      onSurface: const Color.fromARGB(255, 168, 168, 168),
    ),
    appBarTheme: _darkAppBarTheme,
    textTheme: _darkTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    bottomNavigationBarTheme: _darkBottomNavigationBarTheme,
    inputDecorationTheme: _darkInputDecorationTheme,
  );

  // Private Theme Configurations for Light
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: Color.fromARGB(255, 242, 244, 247),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static final TextTheme _lightTextTheme = ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      );

  static const BottomNavigationBarThemeData _lightBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 242, 244, 247),
    selectedItemColor: blueColor,
    unselectedItemColor: Color.fromARGB(255, 158, 158, 158),
  );

  static final InputDecorationTheme _lightInputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: blueColor),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: blueColor),
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: const TextStyle(color: blueColor),
    hintStyle: const TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
  );

  // Private Theme Configurations for Dark
  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    backgroundColor: Color.fromARGB(255, 48, 48, 48),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static final TextTheme _darkTextTheme = ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      );

  static const BottomNavigationBarThemeData _darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 18, 18, 18),
    selectedItemColor: darkBlueColor,
    unselectedItemColor: Color.fromARGB(255, 117, 117, 117),
  );

  static final InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: darkBlueColor),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: darkBlueColor),
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: const TextStyle(color: darkBlueColor),
    hintStyle: const TextStyle(color: Color.fromARGB(255, 117, 117, 117)),
  );

  // Shared Button Style
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        foregroundColor: const Color.fromARGB(255, 242, 244, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: Colors.white,
        )),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: blueColor,
    ),
  );

  static final ButtonStyle lightGreenButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: lightGreenColor,
      foregroundColor: Color.fromARGB(255, 242, 244, 247),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Colors.white,
      ));
}
