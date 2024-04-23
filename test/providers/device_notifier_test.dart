// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import '../shared.dart';

class FakeBleDevice extends BleDevice {
  FakeBleDevice({
    this.isConnected = false,
  }) : super(DiscoveredDevice(
            id: "id",
            name: "name",
            serviceData: const <Uuid, Uint8List>{},
            manufacturerData: Uint8List(0),
            rssi: 0,
            serviceUuids: const []));

  @override
  bool isConnected;

  bool shouldThrowException = false;

  @override
  void disconnect() {
    isConnected = false;
  }

  @override
  Future<void> connect() async {
    if (shouldThrowException) {
      throw Exception("Failed to connect");
    }
  }

  @override
  Future<void> waitForPair({int? timeout}) async {
    if (shouldThrowException) {
      throw Exception("Failed to pair");
    }
  }
}

void main() async {
  testInit();

  test("Device can be set", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    notifier.setDevice(device);
    expect(notifier.device, device);
  });

  test("Listeners are notified when device is set", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    notifier.setDevice(device);
    expect(notified, true);
  });

  test("Device can be reset", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    notifier.setDevice(device);
    notifier.resetDevice();
    expect(notifier.device, null);
  });

  test("Listeners are notified when device is reset", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    notifier.setDevice(device);
    notifier.resetDevice();
    expect(notified, true);
  });

  test("Resetting device also disconnects the device", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice(isConnected: true);
    notifier.setDevice(device);
    notifier.resetDevice();
    expect(device.isConnected, false);
  });

  test("Notifies listeners when connection status changes", () {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    notifier.setDevice(device);
    notifier.listenForConnectionEvents();
    device.emit(BleDeviceClientEvents.connected, null);
    expect(notified, true);
    notified = false;
    device.emit(BleDeviceClientEvents.disconnected, null);
    expect(notified, true);
  });

  test("Connecting to device succeeds and notifies listeners", () async {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    notifier.setDevice(device);
    await notifier.connect();
    expect(notifier.hasError(), false);
    expect(notified, true);
  });

  test("Connecting to device fails and notifies listeners", () async {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    device.shouldThrowException = true;
    notifier.setDevice(device);
    await notifier.connect();
    expect(notifier.hasError(), true);
    expect(notified, true);
  });

  test("Pairing with device succeeds and notifies listeners", () async {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    notifier.setDevice(device);
    await notifier.pair();
    expect(notifier.hasError(), false);
    expect(notified, true);
  });

  test("Pairing with device fails and notifies listeners", () async {
    final notifier = DeviceNotifier();
    final device = FakeBleDevice();
    bool notified = false;
    notifier.addListener(() {
      notified = true;
    });
    device.shouldThrowException = true;
    notifier.setDevice(device);
    await notifier.pair();
    expect(notifier.hasError(), true);
    expect(notified, true);
  });
}
