import 'package:binsight_ai/util/bluetooth_exception.dart';

class BleExceptionDialogStrings {
  BleExceptionDialogStrings(this.title, this.description);
  final String title;
  final String description;
}

/// Returns the title and description for a given exception.
BleExceptionDialogStrings getStringsFromException(Exception? error) {
  String title;
  String description;
  if (error is BleBluetoothNotSupportedException) {
    title = "Bluetooth is not supported";
    description =
        "This device does not support Bluetooth, which is required for this step. To still receive data, manually enter your bin's ID via the help menu.";
  } else if (error is BleBluetoothDisabledException) {
    title = "Bluetooth is disabled";
    description = "Please enable Bluetooth to continue set up.";
  } else if (error is BlePermissionException) {
    title = "Insufficient permissions";
    description = """
Please grant the necessary permissions to continue.
To do so, restart this app or head to your system's application settings and manually grant the permissions.
You may need to restart the app after granting permissions.
The error message was: '${error.message}'.
            """;
  } else if (error is BleConnectionException) {
    title = "Failed to connect";
    description =
        "Failed to connect to the bin. Please make sure the bin is powered on and in range.";
  } else if (error is BleInvalidOperationException ||
      error is BleOperationFailureException) {
    title = "Operation failed";
    description = """
An operation failed. Please try again. You may need to reset your bluetooth settings, restart the bin, try again, or restart the app.
The error message was: '${error.toString()}'.
    """;
  } else {
    throw UnimplementedError(
        "Error $error is not handled in getStringsFromException");
  }
  return BleExceptionDialogStrings(title, description);
}
