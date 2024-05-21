// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/async_ops.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/bluetooth_dialog_strings.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/styles.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/bluetooth_alert_box.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';
import 'package:binsight_ai/widgets/scan_list.dart';

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
          if (!(device.isConnected && device.isBonded)) {
            dialogIsVisible = true;
            runSoon(() {
              deviceNotifier.connect();
              showDialog(
                context: context,
                builder: connectingDialogBuilder,
                barrierDismissible: false,
              );
            });
          }
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
        if (device == null) return const SizedBox();
        if (deviceNotifier.hasError()) {
          final strings = getStringsFromException(error);
          return ErrorDialog(
              text: strings.title,
              description: strings.description,
              callback: () {
                Navigator.of(context).pop();
                setState(() {
                  dialogIsVisible = false;
                  deviceNotifier.resetDevice();
                });
              });
        } else if (device.isConnected) {
          Future.delayed(
            const Duration(
              seconds: 2,
            ),
            () {
              Provider.of<SetupKeyNotifier>(context, listen: false)
                  .setupKey
                  .currentState
                  ?.next();
              Navigator.of(context).pop();
            },
          );
          return BluetoothAlertBox(
            title: Text(
              "Bluetooth connection complete! Moving on...",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            content: const SizedBox(
              height: 50,
              child: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        } else {
          return BluetoothAlertBox(
            title: Text(
              "Connecting...",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            content: const SizedBox(
              height: 50,
              child: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }
      },
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

  /// Whether the scanner is currently scanning for devices.
  bool isScanning = false;

  /// An error that may occur during the scanning process.
  Exception? error;

  /// Whether the dialog is currently visible.
  bool isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    startScanning();
    widget.scanner.onDeviceListUpdated(onDeviceListUpdated);
    isScanning = true;
  }

  @override
  void dispose() {
    isScanning = false;
    stopScanning();
    widget.scanner.removeListener(
        BleDeviceScannerEvents.deviceListUpdated, onDeviceListUpdated);
    super.dispose();
  }

  /// Stops scanning for devices.
  void stopScanning() {
    widget.scanner.stopScan();
    isScanning = false;
  }

  /// Starts scanning for devices.
  void startScanning() async {
    try {
      isScanning = true;
      await widget.scanner.startScan(serviceFilter: [mainServiceId]);
    } on Exception catch (e) {
      debug("BLE LIST ERROR");
      debug(e);
      stopScanning();
      if (!mounted) return;
      setState(() {
        error = e;
      });
    }
  }

  /// Updates the list of devices found by the scanner.
  void onDeviceListUpdated(List<BleDevice> deviceList) {
    setState(() {
      devices = deviceList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error != null && !isDialogVisible) {
      isDialogVisible = true;
      runSoon(() {
        showDialog(context: context, builder: displayErrorDialog);
      });
    }

    return Scaffold(
      body: CustomBackground(
        imageURL: 'assets/images/bluetooth_screen.png',
        child: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height / 2) - (336),
            ),
            ScanList(
              itemCount: devices.length,
              listBuilder: buildDeviceItem,
              onResume: () {
                setState(() {
                  startScanning();
                });
              },
              title: "Find your bin!",
              inProgress: isScanning,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Displays an error dialog.
  Widget displayErrorDialog(BuildContext context) {
    final strings = getStringsFromException(error);
    return ErrorDialog(
        text: strings.title,
        description: strings.description,
        callback: () {
          isDialogVisible = false;
          Navigator.of(context).pop();
          setState(() {
            error = null;
          });
        });
  }

  /// Builds a list item for a Bluetooth device.
  ///
  /// When pressed, the device is set as the current device.
  /// This should trigger a connection attempt. See [BluetoothPage].
  Widget buildDeviceItem(BuildContext context, int index) {
    final device = devices[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: bluetoothBorderRadius,
      child: ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              stopScanning();
              final deviceProvider =
                  Provider.of<DeviceNotifier>(context, listen: false);
              deviceProvider.setDevice(device);
              deviceProvider.listenForConnectionEvents();
            });
          }),
    );
  }
}
