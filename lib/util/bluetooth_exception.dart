class BlePermissionException implements Exception {
  final String message;

  BlePermissionException(this.message);

  @override
  String toString() {
    return "BlePermissionException: $message";
  }
}

class BleBluetoothNotSupportedException implements Exception {
  final String message;

  BleBluetoothNotSupportedException(this.message);

  @override
  String toString() {
    return "BleBluetoothNotSupportedException: $message";
  }
}

class BleBluetoothDisabledException implements Exception {
  final String message;

  BleBluetoothDisabledException(this.message);

  @override
  String toString() {
    return "BleBluetoothDisabledException: $message";
  }
}

class BleConnectionException implements Exception {
  final String message;

  BleConnectionException(this.message);

  @override
  String toString() {
    return "BleConnectionException: $message";
  }
}

class BleInvalidOperationException implements Exception {
  final String message;

  BleInvalidOperationException(this.message);

  @override
  String toString() {
    return "BleInvalidOperationException: $message";
  }
}

class BleOperationFailureException implements Exception {
  final String message;

  BleOperationFailureException(this.message);

  @override
  String toString() {
    return "BleOperationFailureException: $message";
  }
}
