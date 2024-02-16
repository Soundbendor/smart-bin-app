import 'dart:async';
import 'dart:io';

import 'package:binsight_ai/util/bluetooth_exception.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleDeviceScannerEvents {
  deviceFound,
  deviceLost,
  deviceListUpdated,
}

/// Requests the necessary permissions for scanning and connecting.
Future<void> requestBluetoothPermissions() async {
  if (Platform.isAndroid) {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      throw BlePermissionException("Fine location permission denied");
    } else {
      debug("BleDeviceScanner: Fine location permission granted");
    }
    status = await Permission.bluetoothScan.request();
    if (status != PermissionStatus.granted) {
      throw BlePermissionException("Bluetooth scan permission denied");
    } else {
      debug("BleDeviceScanner: Bluetooth scan permission granted");
    }
    status = await Permission.bluetoothConnect.request();
    if (status != PermissionStatus.granted) {
      throw BlePermissionException("Bluetooth connect permission denied");
    } else {
      debug("BleDeviceScanner: Bluetooth connect permission granted");
    }
  } else {
    if (await Permission.bluetooth.isRestricted) {
      final status = await Permission.bluetooth.request();
      if (status != PermissionStatus.granted) {
        throw BlePermissionException("Bluetooth permission denied");
      } else {
        debug("BleDeviceScanner: Bluetooth permission granted");
      }
    }
  }
}

/// A Bluetooth device.
class BleDevice {
  /// Initial [DiscoveredDevice] used to create the [BleDevice].
  ///
  /// Used to retreive the device's ID, name, and service UUIDs.
  final DiscoveredDevice _discoveredDevice;

  BleDevice(this._discoveredDevice);

  /// The device's ID.
  String get id => _discoveredDevice.id.toString();
  /// The device's name.
  String get name => _discoveredDevice.name;
  /// The device's service UUIDs.
  List<Uuid> get serviceIds => _discoveredDevice.serviceUuids;
}

/// Manages scanned Bluetooth devices and emits relevant events.
class BleDeviceScanner {
  /// Whether the scanner is currently scanning for devices.
  bool isScanning = false;

  /// Used to emit events.
  final _emitter = EventEmitter();

  /// A map of device IDs to devices.
  final _scannedDevices = <String, BleDevice>{};

  /// A map of device IDs to the time they were last scanned.
  final _scannedDevicesTime = <String, DateTime>{};

  /// The FlutterReactiveBle instance used to scan for devices.
  final _reactiveScanner = FlutterReactiveBle();

  /// The subscription to the scan stream.
  StreamSubscription? _scanSubscription;

  /// Starts scanning for devices.
  Future<void> startScan({List<Uuid>? serviceFilter}) async {
    // check permissions and Bluetooth support
    if (await FlutterBluePlus.isSupported) {
      await requestBluetoothPermissions();
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on &&
          FlutterBluePlus.adapterStateNow != BluetoothAdapterState.unknown) {
        throw BleBluetoothDisabledException("Bluetooth is not turned on");
      }
    } else {
      throw BleBluetoothNotSupportedException(
          "Bluetooth is not supported on this device");
    }
    isScanning = true;
    _scanSubscription = _reactiveScanner
        .scanForDevices(withServices: serviceFilter ?? [])
        .listen(_handleDiscoveredDevice);
    _runDeviceTimer();
  }

  /// Stops scanning for devices.
  Future<void> stopScan() async {
    isScanning = false;
    await _scanSubscription?.cancel();
  }

  /// Runs the timer while the scan is going.
  ///
  /// It removes devices that haven't been seen in a while.
  void _runDeviceTimer() async {
    while (isScanning) {
      final now = DateTime.now();
      for (final deviceEntry in _scannedDevicesTime.entries) {
        if (now.difference(deviceEntry.value).inSeconds > 10) {
          _scannedDevices.remove(deviceEntry.key);
          _scannedDevicesTime.remove(deviceEntry.key);
          _emit<BleDevice>(BleDeviceScannerEvents.deviceLost,
              _scannedDevices[deviceEntry.key]!);
          _emit<List<BleDevice>>(BleDeviceScannerEvents.deviceListUpdated,
              _scannedDevices.values.toList());
          debug("BleDeviceScanner: Device ${deviceEntry.key} lost");
        } else {
          _scannedDevicesTime[deviceEntry.key] = now;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Manages internal state when a device is discovered.
  void _handleDiscoveredDevice(DiscoveredDevice device) {
    final bleDevice = BleDevice(device);
    if (!_scannedDevices.containsKey(bleDevice.id)) {
      _scannedDevices[bleDevice.id] = bleDevice;
      _scannedDevicesTime[bleDevice.id] = DateTime.now();
      _emit<BleDevice>(BleDeviceScannerEvents.deviceFound, bleDevice);
      _emit<List<BleDevice>>(BleDeviceScannerEvents.deviceListUpdated,
          _scannedDevices.values.toList());
      debug("BleDeviceScanner: Device ${bleDevice.id} found");
    } else {
      _scannedDevicesTime[bleDevice.id] = DateTime.now();
    }
  }

  // events
  void _emit<T>(BleDeviceScannerEvents event, T data) {
    _emitter.emit(event.name, data);
  }

  /// Creates a listener for the given event type.
  void on<T>(BleDeviceScannerEvents type, dynamic Function(T) callback) {
    _emitter.on(type.name, callback);
  }

  /// Creates a listener for the given event type that will only be called once.
  ///
  /// Can be awaited.
  Future<T> once<T>(BleDeviceScannerEvents type, dynamic Function(T) callback) {
    return _emitter.once(type.name, callback);
  }

  /// Removes a listener for the given event type.
  void off<T>(BleDeviceScannerEvents type, dynamic Function(T) callback) {
    _emitter.off(type: type.name, callback: callback);
  }

  /// Creates a listener which is run when a device is found.
  void onDeviceFound(Function(BleDevice) callback) {
    on(BleDeviceScannerEvents.deviceFound, callback);
  }

  /// Creates a listener which is run when a device is lost.
  void onDeviceLost(Function(BleDevice) callback) {
    on(BleDeviceScannerEvents.deviceLost, callback);
  }

  /// Creates a listener which is run when the device list is updated.
  void onDeviceListUpdated(Function(List<BleDevice>) callback) {
    on(BleDeviceScannerEvents.deviceListUpdated, callback);
  }
}
