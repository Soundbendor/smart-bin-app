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
