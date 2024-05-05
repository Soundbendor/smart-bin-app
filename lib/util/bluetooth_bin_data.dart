// Package imports:
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// The main service ID for the Bluetooth device.
///
/// Contains the WiFi status, WiFi credentials, and WiFi list characteristics.
final mainServiceId = Uuid.parse("31415924535897932384626433832790");

/// The characteristic ID for the WiFi status.
///
/// May be read.
///
/// Returns a JSON object with details about the WiFi status.
/// ```js
/// // success
/// {
///   "message": "Connected to MyWifi is Beautiful",
///   "success": true,
///   "internet_access": true, // or false if connected to WiFi but no internet
/// }
///
/// // failure
/// {
///   "message": "Not connected to Wi-Fi",
///   "success": false,
/// }
/// ```
final wifiStatusCharacteristicId =
    Uuid.parse("31415924535897932384626433832791");

/// The characteristic ID for the WiFi credentials.
///
/// May be read or written to.
///
/// Returns a JSON object with details about previous operations.
/// ```js
/// {
///   "message": "Wi-Fi configuration successful",
///   "success": true,
///   "log": "...", // log of the operation (useful for errors)
///   "timestamp": 123456789.5 // Unix timestamp (seconds)
/// }
/// ```
///
/// When written to, the value should be a JSON object like the following:
/// ```js
/// {
///   "ssid": "MyWifi is Beautiful",
///   "password": "password123"
/// }
/// ```
final wifiCredentialCharacteristicId =
    Uuid.parse("31415924535897932384626433832792");

/// The characteristic ID for the WiFi list.
///
/// May be read or listened to.
///
/// Returns a JSON array of WiFi networks.
/// ```js
/// [
///   ["SSID", "SECURITY (WPA2, --, etc.)", "SIGNAL STRENGTH (0-100)"],
///   ["MyWifi is Beautiful", "WPA2", 100],
/// ]
/// ```
final wifiListCharacteristicId = Uuid.parse("31415924535897932384626433832793");

/// The API service ID for the Bluetooth device.
///
/// Contains the API key/Device ID characteristic and heartbeat characteristic
final apiServiceId = Uuid.parse("72604136186287082325955290141510");

/// The characteristic ID for getting the heartbeat result to verify API is working.
///
/// Note: Unused by the app
final heartBeatCharacteristicId =
    Uuid.parse("72604136186287082325955290141511");

/// The characteristic ID for the API key/Device ID.
///
/// May be read.
///
/// Returns a JSON object with the API key and device ID.
/// ```js
/// {
///   "apiKey": "1234567890",
///   "deviceID": "1234567890"
/// }
/// ```
final apiKeyCharacteristicId = Uuid.parse("72604136186287082325955290141512");
