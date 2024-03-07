import 'package:flutter/material.dart';

final mainColorScheme = ColorScheme(
  primary: const Color.fromARGB(255, 22, 151, 201),
  onPrimary: Colors.white,
  secondary: Colors.blueAccent.shade700,
  onSecondary: Colors.white,
  tertiary: const Color.fromARGB(255, 116, 193, 164),
  onTertiary: Colors.white,
  error: Colors.red,
  onError: Colors.red.shade700,
  background: const Color(0xFFeef8f4),
  onBackground: const Color(0xFF333333),
  brightness: Brightness.light,
  surface: Colors.grey.shade200,
  onSurface: Colors.black,
);

final mainTheme = ThemeData(
  colorScheme: mainColorScheme,

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      fontFamily: 'Georama', // Specify the font family
    ),
      headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.normal,
      fontFamily: 'GolosText', // Specify the font family
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: mainColorScheme.primary,
      foregroundColor: mainColorScheme.onPrimary,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: mainColorScheme.primary,
        foregroundColor: mainColorScheme.onPrimary),
  ),

  cardTheme: CardTheme(
    surfaceTintColor: mainColorScheme.onSurface,
    shadowColor: mainColorScheme.onBackground,
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),

);
