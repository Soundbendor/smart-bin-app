// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:rotating_icon_button/rotating_icon_button.dart';

// Project imports:
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/util/smart_bin_device.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:provider/provider.dart';

/// Displays the detections with padding and a size toggle button.
class DetectionsPage extends StatefulWidget {
  const DetectionsPage({super.key});

  @override
  State<DetectionsPage> createState() => DetectionsPageState();
}

class DetectionsPageState extends State<DetectionsPage> {
  /// Whether to display the detections in a large or small format.
  ///
  /// When [sizeToggle] is true, the detections are displayed in a large card format.
  /// When [sizeToggle] is false, the detections are displayed in a small list format.
  bool sizeToggle = false;

  /// The list of detections to display.
  List<Detection> detections = [];

  /// A future that loads the initial list of detections.
  late Future loadDetectionFuture;

  @override
  void initState() {
    loadDetectionFuture = loadDetections(context, showSnackBar: false);
    super.initState();
  }

  void connectToDevice(BuildContext context) async {
    showDialog(context: context, builder: (BuildContext context) {
      if 
      return AlertDialog();
      });
    late final bool wifiConnectedToInternet;
    Device device = (await Device.all()).first;
    BleDevice bledevice = BleDevice.fromId(device.id);
    if (!context.mounted) return;
    DeviceNotifier notifierProvider =
        Provider.of<DeviceNotifier>(context, listen: false);
    notifierProvider.setDevice(bledevice);
    await notifierProvider.connect();
    // if (!context.mounted) return;
    notifierProvider.listenForConnectionEvents();
    await notifierProvider.pair();

    final statusCharacteristic = await notifierProvider.device
        ?.readCharacteristic(
            serviceId: mainServiceId,
            characteristicId: wifiStatusCharacteristicId);

    // if (!context.mounted) return;
    final Map<String, dynamic> statusJson =
        await SmartBinDevice.decodeCharacteristic(
            context, statusCharacteristic!);
    if (statusJson["success"]) {
      wifiConnectedToInternet = statusJson["internet_access"];
    }

    Navigator.of(context).pop();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("WiFi Connection Status"),
          content: Text(wifiConnectedToInternet
              ? "All good! You were already connected, did you want to select a new network?."
              : "Oops! Your bin was disconnected from the internet. Reconnect now?"),
          actions: !wifiConnectedToInternet
              ? <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed("wifi-scan");
                    },
                    child: const Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("No"),
                  )
                ]
              : null,
        );
      },
    );
  }

  /// Displays a dialog that asks the user if they would like to check their
  /// WiFi status or not.
  Future checkWifi() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Check WiFi Connection?"),
            content: Text(
                "Note: This will require a Bluetooth Connection to your bin.",
                style: Theme.of(context).textTheme.bodyLarge),
            actions: [
              TextButton(
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                onPressed: () {
                  // Removes the dialog
                  Navigator.of(context).pop();
                },
                child: Text(
                  "No",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(250),
                      ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  // Removes the dialog and takes the user back to the bluetooth setup screen
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text("Connecting to Bluetooth"),
                          content: SizedBox(
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
                      });
                  connectToDevice(context);
                  // once it connects, read the characteristic that says if it's connected or not
                },
                child: const Text("Yes"),
              ),
            ],
          );
        });
  }

  /// Function that returns all detections from the database after a simulated delay.
  ///
  /// If [showSnackBar] is true, the snackBar will be rendered after the refresh.
  /// If [showSnackBar] is false, the snackBar will not be rendered after the refresh.
  ///
  /// Tapping the snackBar will trigger a call to [checkWifi].
  Future<void> loadDetections(BuildContext context,
      {bool showSnackBar = true}) {
    return Future.delayed(const Duration(seconds: 2), () {
      return Detection.all().then((value) async {
        // Access the detections before the refresh to compare afterwards
        List<Detection> previousDetections = detections;
        setState(() {
          detections = value;
        });
        // If the new detections list is larger than the old one, there are new detections
        bool areNewDetections = previousDetections.length != detections.length;
        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 15),
              content: Text(
                areNewDetections
                    ? "New detections found. Happy annotating!"
                    : "No new detections found. Tap here if you were expecting some.",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
              backgroundColor: areNewDetections ? Colors.green : Colors.blue,
              action: SnackBarAction(label: "Check", onPressed: checkWifi),
              showCloseIcon: true,
            ),
          );
        }
      });
    });
  }

  // Toggles the small/large detection card size
  void onToggleSwitch(bool value) {
    setState(() {
      sizeToggle = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Heading(text: "Detections")),
                // The switch to toggle detection card size
                Switch(
                    value: sizeToggle,
                    onChanged: onToggleSwitch,
                    thumbColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.onPrimary;
                      }
                      return Theme.of(context).colorScheme.onSurface;
                    }),
                    trackOutlineColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onBackground,
                    ),
                    trackColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Theme.of(context).colorScheme.surface;
                    })),
                Text(
                  "Image Size",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                RotatingIconButton(
                  onTap: () => loadDetections(context),
                  rotateType: RotateType.full,
                  child: const Icon(Icons.refresh, size: 40, weight: 75),
                ),
              ],
            ),
            // Display a loading icon until the detections are gathered from the database
            FutureBuilder(
                future: loadDetectionFuture,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? const CircularProgressIndicator()
                      : DetectionList(
                          size: sizeToggle
                              ? DetectionListType.large
                              : DetectionListType.small,
                          detections: detections,
                          loadDetections: loadDetections);
                })
          ],
        ),
      ),
    );
  }
}
