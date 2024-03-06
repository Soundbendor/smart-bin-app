import 'package:flutter/material.dart';

final mainColorScheme = ColorScheme(
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent.shade700,
  onSecondary: Colors.white,
  tertiary: Colors.green.shade700,
  onTertiary: Colors.white,
  error: Colors.red,
  onError: Colors.red.shade700,
  background: Colors.white,
  onBackground: Colors.black,
  brightness: Brightness.light,
  surface: Colors.grey.shade200,
  onSurface: Colors.black,
);

final mainTheme = ThemeData(
  colorScheme: mainColorScheme,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
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
    surfaceTintColor: mainColorScheme.onSurface,
    shadowColor: mainColorScheme.onBackground,
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

final bluetoothBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(15),
);
