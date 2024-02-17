import 'package:binsight_ai/util/bluetooth_exception.dart';

class BleExceptionDialogStrings {
  BleExceptionDialogStrings(this.title, this.description);
  final String title;
  final String description;
}

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
              To do so, head to your system's application settings and manually grant the permissions.
              You may need to restart the app after granting permissions.
              The error message was: '${error.message}'.
            """;
  } else if (error is BleConnectionException) {
    title = "Failed to connect";
    description =
        "Failed to connect to the bin. Please make sure the bin is powered on and in range.";
  } else {
    throw UnimplementedError(
        "Error $error is not handled in connectingDialogBuilder");
  }
  return BleExceptionDialogStrings(title, description);
}
