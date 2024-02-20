import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/bluetooth_dialog_strings.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';

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
          if (device.isConnected) {
            Future.delayed(Duration.zero, () {
              GoRouter.of(context).goNamed('wifi-scan');
            });
          } else {
            dialogIsVisible = true;
            Future.delayed(Duration.zero, () {
              deviceNotifier.connect();
              showDialog(
                  context: context,
                  builder: connectingDialogBuilder,
                  barrierDismissible: false);
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
        } else if (device!.isConnected) {
          Future.delayed(Duration.zero, () {
            GoRouter.of(context).goNamed('wifi-scan');
          });
          dialogIsVisible = false;
          return const SizedBox();
        } else {
          return AlertDialog(
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
                      child: CircularProgressIndicator())),
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
      Future.delayed(Duration.zero, () {
        showDialog(context: context, builder: displayErrorDialog);
      });
    }

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
        isScanning
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    startScanning();
                  });
                },
                child: Text("Resume Scan",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
              ),
      ],
    )));
  }

  /// Displays an error dialog.
  Widget displayErrorDialog(BuildContext context) {
    final strings = getStringsFromException(error);
    return ErrorDialog(
        text: strings.title,
        description: strings.description,
        callback: () {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              stopScanning();
              final deviceProvider = Provider.of<DeviceNotifier>(context, listen: false);
              deviceProvider.setDevice(device);
              deviceProvider.listenForConnectionEvents();
            });
          }),
    );
  }
}
