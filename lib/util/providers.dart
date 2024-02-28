import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/util/bluetooth.dart';

/// Notifies listeners of changes to the device.
///
/// This also includes the device's connection status.
class DeviceNotifier with ChangeNotifier {
  BleDevice? device;

  /// An error that occurred during the connection process.
  Exception? error;

  /// Whether an error occurred during the connection process.
  bool hasError() {
    return error != null;
  }

  /// Sets the device to the new device and notifies listeners.
  void setDevice(BleDevice newDevice) {
    device = newDevice;
    notifyListeners();
  }

  /// Resets and disconnects the device.
  void resetDevice() async {
    device?.removeListener(
        BleDeviceClientEvents.connected, _onConnectionChange);
    device?.removeListener(
        BleDeviceClientEvents.disconnected, _onConnectionChange);
    device?.disconnect();
    device = null;
    notifyListeners();
  }

  /// Notifies listeners of a change in the connection status.
  void _onConnectionChange(_) {
    notifyListeners();
  }

  /// Listens for connection events on the device.
  void listenForConnectionEvents() {
    device?.onConnected(_onConnectionChange);
    device?.onDisconnected(_onConnectionChange);
  }

  /// Pairs with the device and notifies when the pairing is complete.
  ///
  /// This method can be awaited to wait for the pairing to complete.
  Future<void> pair() async {
    try {
      error = null;
      await device?.waitForPair();
    } on Exception catch (e) {
      debug("DeviceNotifier[pair]: Failed: $e");
      error = e;
    }
    notifyListeners();
  }

  /// Connects to the device and notifies when the connection is complete.
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
