import 'dart:async';
import 'dart:convert';
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

enum BleDeviceClientEvents {
  connected,
  disconnected,
  notification,
}

enum _BleSubscriptionType {
  subscribe,
  connection,
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
  BleDevice(this._discoveredDevice) {
    _device = BluetoothDevice(remoteId: DeviceIdentifier(id));
  }

  /// Initial [DiscoveredDevice] used to create the [BleDevice].
  ///
  /// Used to retreive the device's ID, name, and service UUIDs.
  final DiscoveredDevice _discoveredDevice;

  /// The connected [BluetoothDevice].
  ///
  /// Used for connection and communication.
  late BluetoothDevice _device;

  /// Used to emit events.
  final _emitter = EventEmitter();

  /// A list of subscriptions to rebuild when the device disconnects and reconnects.
  final _rebuildSubscriptionList = <List<dynamic>>[];

  Future? _connectionFuture;

  /// Whether the device should be connected.
  ///
  /// Used to reconnect to the device after an unexpected disconnection.
  bool _shouldBeConnected = false;

  /// Whether the device is currently connecting.
  bool isConnecting = false;

  /// The device's ID.
  String get id => _discoveredDevice.id.toString();

  /// The device's name.
  String get name => _discoveredDevice.name;

  /// The device's service UUIDs.
  List<Uuid> get serviceIds => _discoveredDevice.serviceUuids;

  /// Whether the device is connected.
  bool get isConnected => _device.isConnected;

  /// Rebuilds subscriptions when the device disconnects and reconnects automatically.
  Future<void> _rebuildSubscriptions() async {
    debug("BleDevice[_rebuildSubscriptions]: Rebuilding subscriptions");
    final subscriptionList = List.from(_rebuildSubscriptionList);
    _rebuildSubscriptionList.clear();
    for (final subscription in subscriptionList) {
      if (subscription[0] == _BleSubscriptionType.subscribe) {
        int attempts = 0;
        while (attempts < 3) {
          try {
            await subscribeToCharacteristic(
                serviceId: subscription[1],
                characteristicId: subscription[2],
                onNotification: subscription[3]);
            break;
          } catch (e) {
            attempts++;
            debug(
                "BleDevice[_rebuildSubscriptions]: ($attempts/3) Error rebuilding subscription: $e");
          }
          if (attempts == 3) {
            disconnect();
            throw BleConnectionException("Failed to rebuild subscriptions");
          }
        }
      } else if (subscription[0] == _BleSubscriptionType.connection) {
        _createConnectionStateSubscription();
      }
    }
  }

  /// Creates a subscription to the device's connection state.
  void _createConnectionStateSubscription() {
    final stream = _device.connectionState.listen((status) {
      if (status == BluetoothConnectionState.disconnected) {
        _emit(BleDeviceClientEvents.disconnected, null);
        if (_shouldBeConnected) {
          connect().onError((error, stackTrace) {
            debug("BleDevice[_createConnectionStateSubscription]: automatic reconnection failed: $error");
          });
        }
      }
    });
    _device.cancelWhenDisconnected(stream, delayed: true);
    _rebuildSubscriptionList.add([_BleSubscriptionType.connection]);
  }

  /// Connects to the device.
  ///
  /// The device will automatically reconnect if it is unexpectedly disconnected.
  /// To stop the device from reconnecting, call [disconnect].
  ///
  /// Throws a [BleConnectionException] if the connection fails.
  Future<void> connect() async {
    if (isConnected) {
      if (!_shouldBeConnected) {
        _shouldBeConnected = true;
        _createConnectionStateSubscription();
      }
      return;
    }
    if (isConnecting) {
      return await _connectionFuture;
    }
    _connectionFuture = _connect();
    return await _connectionFuture;
  }
  Future<void> _connect() async {
    isConnecting = true;
    int attempts = 0;
    while (attempts < 3) {
      try {
        await _device.connect();
        debug("BleDevice[connect]: Connection initialized successfully");
        await _device.discoverServices();
        debug("BleDevice[connect]: Discovered services");
        break;
      } catch (e) {
        attempts++;
        debug(
            "BleDevice[connect]: ($attempts/3) Error connecting to device: $e");
      }
      if (attempts == 3) {
        isConnecting = false;
        throw BleConnectionException("Failed to connect to device");
      }
    }
    if (_shouldBeConnected) {
      await _rebuildSubscriptions();
    } else {
      _createConnectionStateSubscription();
    }
    debug("BleDevice[connect]: Connected to device complete");
    isConnecting = false;
    _shouldBeConnected = true;
    _emit(BleDeviceClientEvents.connected, null);
  }

  /// Disconnects from the device.
  ///
  /// Note: On iOS, the device might not be disconnected.
  /// You may need to notify the user to manually disconnect from the device.
  void disconnect() {
    _shouldBeConnected = false;
    _device.disconnect().ignore();
    _emit(BleDeviceClientEvents.disconnected, null);
  }

  /// Reads a characteristic.
  ///
  /// [serviceId] is the service UUID.
  /// [characteristicId] is the characteristic UUID.
  ///
  /// Throws a [BleInvalidOperationException] if the characteristic does not support reading.
  /// Throws a [BleOperationFailureException] if the read fails.
  /// Throws a [BleConnectionException] if the device fails to connect.
  Future<List<int>> readCharacteristic(
      {required Uuid serviceId, required Uuid characteristicId}) async {
    final characteristic = BluetoothCharacteristic(
        remoteId: DeviceIdentifier(id),
        serviceUuid: Guid.fromBytes(serviceId.data),
        characteristicUuid: Guid.fromBytes(characteristicId.data));
    if (!isConnected) {
      debug(
          "BleDevice[readCharacteristic]: Device not connected, attempting to connect");
      await connect();
    }
    if (!characteristic.properties.read) {
      debug(
          "BleDevice[readCharacteristic][$characteristicId]: read = ${characteristic.properties.read}");
      throw BleInvalidOperationException(
          "Characteristic $characteristicId does not support reading");
    }
    try {
      return await characteristic.read();
    } catch (e) {
      debug("BleDevice[readCharacteristic][$characteristicId]: $e");
      throw BleOperationFailureException(
          "Failed to read characteristic $characteristicId");
    }
  }

  /// Writes a characteristic.
  ///
  /// [serviceId] is the service UUID.
  /// [characteristicId] is the characteristic UUID.
  /// [value] is the value to write. It must be a [List] of [int] or a [String].
  ///
  /// Throws a [BleInvalidOperationException] if the characteristic does not support writing.
  /// Throws a [BleOperationFailureException] if the write fails.
  /// Throws a [BleConnectionException] if the device fails to connect.
  Future<void> writeCharacteristic({
    required Uuid serviceId,
    required Uuid characteristicId,
    required dynamic value,
  }) async {
    if (value is String) {
      value = utf8.encode(value);
    } else if (value is! List<int>) {
      throw BleInvalidOperationException(
          "Value must be a List<int> or a String");
    }
    final characteristic = BluetoothCharacteristic(
        remoteId: DeviceIdentifier(id),
        serviceUuid: Guid.fromBytes(serviceId.data),
        characteristicUuid: Guid.fromBytes(characteristicId.data));
    if (!isConnected) {
      debug(
          "BleDevice[writeCharacteristic]: Device not connected, attempting to connect");
      await connect();
    }
    if (!characteristic.properties.write) {
      debug(
          "BleDevice[writeCharacteristic][$characteristicId]: write = ${characteristic.properties.write}");
      throw BleInvalidOperationException(
          "Characteristic $characteristicId does not support writing");
    }
    try {
      await characteristic.write(value);
    } catch (e) {
      debug("BleDevice[writeCharacteristic][$characteristicId]: $e");
      throw BleOperationFailureException(
          "Failed to write characteristic $characteristicId");
    }
  }

  /// Subscribes to a characteristic.
  ///
  /// [serviceId] is the service UUID.
  /// [characteristicId] is the characteristic UUID.
  /// [onNotification] is a function that is run when a notification is received.
  /// The function is passed a [List] of [int] representing the notification value.
  ///
  /// Throws a [BleInvalidOperationException] if the characteristic does not support subscribing.
  /// Throws a [BleOperationFailureException] if the subscription fails.
  /// Throws a [BleConnectionException] if the device fails to connect.
  Future<void> subscribeToCharacteristic({
    required Uuid serviceId,
    required Uuid characteristicId,
    Function(List<int>)? onNotification,
  }) async {
    final characteristic = BluetoothCharacteristic(
        remoteId: DeviceIdentifier(id),
        serviceUuid: Guid.fromBytes(serviceId.data),
        characteristicUuid: Guid.fromBytes(characteristicId.data));
    if (!isConnected) {
      debug(
          "BleDevice[subscribeToCharacteristic]: Device not connected, attempting to connect");
      await connect();
    }
    if (!characteristic.properties.notify &&
        !characteristic.properties.indicate) {
      debug(
          "BleDevice[subscribeToCharacteristic][$characteristicId]: notify = ${characteristic.properties.notify}, indicate = ${characteristic.properties.indicate}");
      throw BleInvalidOperationException(
          "Characteristic $characteristicId does not support subscribing");
    }
    try {
      await characteristic.setNotifyValue(true);
      final stream = characteristic.lastValueStream.listen((value) {
        _emit(BleDeviceClientEvents.notification,
            [serviceId, characteristicId, value]);
        if (onNotification != null) onNotification(value);
      });
      _device.cancelWhenDisconnected(stream);
      _rebuildSubscriptionList.add([
        _BleSubscriptionType.subscribe,
        serviceId,
        characteristicId,
        onNotification
      ]);
    } catch (e) {
      debug("BleDevice[subscribeToCharacteristic][$characteristicId]: $e");
      throw BleOperationFailureException(
          "Failed to subscribe to characteristic $characteristicId");
    }
  }

  /// Unsubscribes from a characteristic.
  ///
  /// [serviceId] is the service UUID.
  /// [characteristicId] is the characteristic UUID.
  ///
  /// Throws a [BleInvalidOperationException] if the characteristic does not support unsubscribing.
  /// Throws a [BleOperationFailureException] if the unsubscription fails.
  /// Throws a [BleConnectionException] if the device fails to connect.
  Future<void> unsubscribeFromCharacteristic({
    required Uuid serviceId,
    required Uuid characteristicId,
  }) async {
    final characteristic = BluetoothCharacteristic(
        remoteId: DeviceIdentifier(id),
        serviceUuid: Guid.fromBytes(serviceId.data),
        characteristicUuid: Guid.fromBytes(characteristicId.data));
    // remove subscriptions
    List<dynamic>? toRemove;
    for (final subscription in _rebuildSubscriptionList) {
      if (subscription[0] == _BleSubscriptionType.subscribe &&
          subscription[1] == serviceId &&
          subscription[2] == characteristicId) {
        toRemove = subscription;
        break;
      }
    }
    _rebuildSubscriptionList.remove(toRemove);
    if (!isConnected) {
      debug(
          "BleDevice[unsubscribeFromCharacteristic]: Device not connected, attempting to connect");
      await connect();
    }
    if (!characteristic.properties.notify &&
        !characteristic.properties.indicate) {
      debug(
          "BleDevice[unsubscribeFromCharacteristic][$characteristicId]: notify = ${characteristic.properties.notify}, indicate = ${characteristic.properties.indicate}");
      throw BleInvalidOperationException(
          "Characteristic $characteristicId does not support unsubscribing");
    }
    try {
      await characteristic.setNotifyValue(false);
    } catch (e) {
      debug("BleDevice[unsubscribeFromCharacteristic][$characteristicId]: $e");
      throw BleOperationFailureException(
          "Failed to unsubscribe from characteristic $characteristicId");
    }
  }

  // events
  /// Creates a listener which is run when the device is connected.
  void onConnected(Function(Null) callback) {
    on(BleDeviceClientEvents.connected, callback);
  }

  /// Creates a listener which is run when the device is disconnected.
  void onDisconnected(Function(Null) callback) {
    on(BleDeviceClientEvents.disconnected, callback);
  }

  /// Emits an event with data.
  void _emit<T>(BleDeviceClientEvents event, T data) {
    _emitter.emit(event.name, data);
  }

  /// Creates a listener for the given event type.
  void on<T>(BleDeviceClientEvents type, dynamic Function(T) callback) {
    _emitter.on(type.name, callback);
  }

  /// Creates a listener for the given event type that will only be called once.
  ///
  /// Can be awaited.
  Future<T> once<T>(BleDeviceClientEvents type, dynamic Function(T) callback) {
    return _emitter.once(type.name, callback);
  }

  /// Removes a listener for the given event type.
  void removeListener<T>(
      BleDeviceClientEvents type, dynamic Function(T) callback) {
    _emitter.off(type: type.name, callback: callback);
  }
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
  ///
  /// [serviceFilter] is a list of service UUIDs to filter by. If null, all devices will be scanned.
  ///
  /// Throws a [BleBluetoothDisabledException] if Bluetooth is not turned on.
  /// Throws a [BleBluetoothNotSupportedException] if Bluetooth is not supported on the device.
  /// Throws a [BlePermissionException] if the necessary permissions are not granted.
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

  /// Emits an event with data.
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
  void removeListener<T>(
      BleDeviceScannerEvents type, dynamic Function(T) callback) {
    _emitter.off(type: type.name, callback: callback);
  }
}
