import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_exception.dart';
import 'package:flutter/material.dart';

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
