// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

/// Initializes SharedPreferences app-wide using a singleton pattern.
Future<void> initPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}