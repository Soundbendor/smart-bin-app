// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

/// Initializes SharedPreferences app-wide using a singleton pattern.
Future<void> initPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

/// Keys for the SharedPreferences.
class SharedPreferencesKeys {
  /// Whether to show the annotation tutorial.
  static const String dontShowAgain = 'dontShowAgain';

  /// The device ID of the connected device.
  ///
  /// Used to reconnect to the device if needed.
  static const String deviceID = 'deviceID';

  /// The API key for the backend API.
  static const String apiKey = 'compostApiKey';

  /// The identifier for the device used in the API.
  ///
  /// Do not confuse this with the device ID used for Bluetooth.
  static const String deviceApiID = 'deviceApiID';
}
