import 'package:flutter/material.dart';
import 'package:binsight_ai/util/bluetooth.dart';

/// Notifies listeners of changes to the device.
///
/// This also includes the device's connection status.
class DeviceNotifier with ChangeNotifier {
  BleDevice? device;

  /// An error that occurred during the connection process.
  Exception? error;

  bool hasError() {
    return error != null;
  }

  void setDevice(BleDevice newDevice) {
    device = newDevice;
    notifyListeners();
  }

  void resetDevice() async {
    device?.disconnect();
    device = null;
    notifyListeners();
  }

  Future<void> connect() async {
    try {
      error = null;
      await device?.connect();
    } on Exception catch (e) {
      error = e;
    }
    notifyListeners();
  }
}
