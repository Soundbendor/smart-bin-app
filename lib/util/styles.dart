// Flutter imports:
import 'package:flutter/material.dart';

final mainColorScheme = ColorScheme(
  primary: const Color.fromARGB(255, 22, 151, 201),
  onPrimary: Colors.white,
  secondary: Colors.blueAccent.shade700,
  onSecondary: Colors.white,
  tertiary: const Color.fromARGB(255, 116, 193, 164),
  onTertiary: Colors.white,
  error: const Color.fromRGBO(236, 106, 44, 1),
  onError: Colors.white,
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
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      fontFamily: 'Georama', // Specify the font family
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.normal,
      fontFamily: 'GolosText', // Specify the font family
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'GolosText', // Specify the font family
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.normal,
      fontFamily: 'GolosText', // Specify the font family
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontFamily: 'GolosText', // Specify the font family
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      fontFamily: 'GolosText', // Specify the font family
    ),
    bodyMedium: TextStyle(
      fontSize: 10,
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
      foregroundColor: mainColorScheme.onPrimary,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shadowColor: mainColorScheme.onBackground,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

final bluetoothBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(15),
);
