import 'package:binsight_ai/util/bluetooth_exception.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/widgets/background.dart';

/// Page which displays scanned Bluetooth devices.
class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  /// Whether the dialog is currently visible.
  ///
  /// While mutable, changing this value doesn't require a rebuild.
  bool dialogIsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceNotifier>(
      builder: (context, deviceNotifier, child) {
        final device = deviceNotifier.device;
        if (device != null && !dialogIsVisible) {
          dialogIsVisible = true;
          showDialog(
              context: context,
              builder: connectingDialogBuilder,
              barrierDismissible: false);
        }
        return child!;
      },
      child: BluetoothList(),
    );
  }

  /// Builds a dialog to display while connecting to a Bluetooth device.
  Widget connectingDialogBuilder(context) {
    return Consumer<DeviceNotifier>(
      builder: (context, deviceNotifier, child) {
        final device = deviceNotifier.device;
        final error = deviceNotifier.error;
        if (deviceNotifier.hasError()) {
          String title;
          String description;
          Function() callback;
          if (error is BleBluetoothNotSupportedException) {
            title = "Bluetooth is not supported";
            description =
                "This device does not support Bluetooth, which is required for this step. To still receive data, manually enter your bin's ID via the help menu.";
            callback = () {
              GoRouter.of(context).goNamed('main');
            };
          } else if (error is BleBluetoothDisabledException) {
            title = "Bluetooth is disabled";
            description = "Please enable Bluetooth to continue set up.";
            callback = () {
              Navigator.of(context).pop();
            };
          } else if (error is BlePermissionException) {
            title = "Insufficient permissions";
            description = """
              Please grant the necessary permissions to continue.
              To do so, head to your system's application settings and manually grant the permissions.
              You may need to restart the app after granting permissions.
              The error message was: ${error.message}
            """;
            callback = () {
              Navigator.of(context).pop();
            };
          } else if (error is BleConnectionException) {
            title = "Failed to connect";
            description =
                "Failed to connect to the bin. Please make sure the bin is powered on and in range.";
            callback = () {
              Navigator.of(context).pop();
            };
          } else {
            throw UnimplementedError(
                "Error $error is not handled in connectingDialogBuilder");
          }
          return ErrorDialog(
            text: title,
            description: description,
            callback: callback,
          );
        } else if (device!.isConnected) {
          GoRouter.of(context).goNamed('wifi-scan');
          dialogIsVisible = false;
          return const SizedBox();
        } else {
          return AlertDialog(
            title: Text(
              "Connecting...",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            content: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.text,
    required this.description,
    required this.callback,
  });

  final String text;
  final String description;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(text, style: Theme.of(context).textTheme.headlineMedium),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: callback,
          child: const Text("OK"),
        ),
      ],
    );
  }
}

/// Displays a list of Bluetooth devices.
class BluetoothList extends StatefulWidget {
  BluetoothList({super.key});

  /// The scanner used to find Bluetooth devices.
  final scanner = BleDeviceScanner();

  @override
  State<BluetoothList> createState() => _BluetoothListState();
}

class _BluetoothListState extends State<BluetoothList> {
  /// The list of devices found by the scanner.
  List<BleDevice> devices = [];

  @override
  void initState() {
    super.initState();
    widget.scanner.startScan(serviceFilter: [mainServiceId]);
    widget.scanner.onDeviceListUpdated(onDeviceListUpdated);
  }

  @override
  void dispose() {
    widget.scanner.stopScan();
    widget.scanner.removeListener(
        BleDeviceScannerEvents.deviceListUpdated, onDeviceListUpdated);
    super.dispose();
  }

  /// Updates the list of devices found by the scanner.
  void onDeviceListUpdated(List<BleDevice> deviceList) {
    setState(() {
      devices = deviceList;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;
    return Scaffold(
        body: CustomBackground(
            child: Column(
      children: [
        SizedBox(
          height: (MediaQuery.of(context).size.height / 2) - (200 + textSize),
        ),
        Text(
          "Find your bin!",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: textSize,
              ),
        ),
        Container(
          color: const Color.fromRGBO(0, 0, 0, 0),
          height: MediaQuery.of(context).size.height / 2.5,
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromARGB(255, 0, 0, 0)
                ],
                stops: [0.0, 0.2, 0.9, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: buildDeviceItem,
            ),
          ),
        ),
      ],
    )));
  }

  /// Builds a list item for a Bluetooth device.
  ///
  /// When pressed, the device is set as the current device.
  /// This should trigger a connection attempt. See [BluetoothPage].
  Widget buildDeviceItem(BuildContext context, int index) {
    final device = devices[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            widget.scanner.stopScan();
            Provider.of<DeviceNotifier>(context, listen: false)
                .setDevice(device);
          }),
    );
  }
}
