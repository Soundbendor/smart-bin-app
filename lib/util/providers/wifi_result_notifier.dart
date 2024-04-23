// Flutter imports:

import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:flutter/material.dart';

class WifiResultNotifier with ChangeNotifier {
  WifiScanResult? wifiResult;

  /// An error that occurred during the connection process.
  Exception? error;

  /// Whether an error occurred during the connection process.
  bool hasError() {
    return error != null;
  }

  /// Sets the device to the new device and notifies listeners.
  void setWifiResult(WifiScanResult newWifiResult) {
    wifiResult = newWifiResult;
    notifyListeners();
  }
}
