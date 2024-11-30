// lib/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color blueColor = Color(0xFF7097BC); // New blue color
  static const Color lightGreenColor = Color(0xFFA6CF98); // Light green color
  static const Color darkBlueColor = Color(0xFF0056B3); // New darker blue color

  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.white,
      secondary: blueColor, // Use the new blue color as the secondary color
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black), // Black icons in AppBar
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black, // Black text across the app
          displayColor: Colors.black,
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor, // Default blue color for elevated buttons
        foregroundColor: Colors.white, // White text on buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: blueColor, // Blue color for text buttons
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: blueColor, // Blue color for selected nav items
      unselectedItemColor: Colors.grey, // Gray for unselected items
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: blueColor),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: blueColor),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: blueColor),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
  );

  // Define a custom button style for the light green button
  static final ButtonStyle lightGreenButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: lightGreenColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
