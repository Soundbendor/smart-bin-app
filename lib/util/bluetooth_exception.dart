/// Thrown when the user denies a required permission
class BlePermissionException implements Exception {
  final String message;

  BlePermissionException(this.message);

  @override
  String toString() {
    return "BlePermissionException: $message";
  }
}

/// Thrown when the device does not support Bluetooth
class BleBluetoothNotSupportedException implements Exception {
  final String message;

  BleBluetoothNotSupportedException(this.message);

  @override
  String toString() {
    return "BleBluetoothNotSupportedException: $message";
  }
}

/// Thrown when Bluetooth is disabled
class BleBluetoothDisabledException implements Exception {
  final String message;

  BleBluetoothDisabledException(this.message);

  @override
  String toString() {
    return "BleBluetoothDisabledException: $message";
  }
}

/// Thrown when the app is unable to connect to the device
class BleConnectionException implements Exception {
  final String message;

  BleConnectionException(this.message);

  @override
  String toString() {
    return "BleConnectionException: $message";
  }
}

/// Thrown when an operation is performed on something that does not support it
class BleInvalidOperationException implements Exception {
  final String message;

  BleInvalidOperationException(this.message);

  @override
  String toString() {
    return "BleInvalidOperationException: $message";
  }
}

/// Thrown when an operation fails (timeout, other error)
class BleOperationFailureException implements Exception {
  final String message;

  BleOperationFailureException(this.message);

  @override
  String toString() {
    return "BleOperationFailureException: $message";
  }
}
