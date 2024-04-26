// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:rotating_icon_button/rotating_icon_button.dart';

// Project imports:
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/async_ops.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/wifi_check_dialog.dart';

/// Displays the detections with padding and a size toggle button.
class DetectionsPage extends StatefulWidget {
  const DetectionsPage({super.key});

  @override
  State<DetectionsPage> createState() => DetectionsPageState();
}

/// A status of the wifi's internet connection.
enum WifiConnectedToInternet {
  /// The wifi did not have an internet connection.
  notConnected,

  /// The status of the wifi internet connection is waiting to be read.
  waiting,

  /// The wifi did have an internet connection.
  connected,
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

  /// Creates and controls a dialog with its own context for the WiFi status check sequence.
  Widget wifiStatusDialogBuilder(context) {
    return const WifiCheckDialog();
  }

  /// Handles reconnecting to the user's device in order to read wifi status characteristic.
  void connectToDevice(BuildContext context) async {
    // Rebuild the user's device from its id to pair and connect
    BleDevice bledevice =
        BleDevice.fromId(sharedPreferences.getString("deviceID")!);
    DeviceNotifier notifierProvider =
        Provider.of<DeviceNotifier>(context, listen: false);
    notifierProvider.setDevice(bledevice);
    await notifierProvider.connect();
    notifierProvider.listenForConnectionEvents();
    await notifierProvider.pair();
  }

  /// Displays a dialog that asks the user if they would like to check their
  /// WiFi status or not.
  Future checkWifi() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Check WiFi Connection?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            content: Text(
                "Note: This will require a Bluetooth Connection to your bin.",
                style: Theme.of(context).textTheme.labelLarge),
            actions: [
              TextButton(
                // Style the button to match the "sad path" color scheme
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
                // Style the button to match the "happy path" color scheme
                style: TextButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.of(context).pop();
                  runSoon(() {
                    // Begin connecting to the device
                    connectToDevice(context);
                    // Display the wifiStatusDialogBuilder throughout the entire WiFi status check process
                    showDialog(
                      context: context,
                      builder: wifiStatusDialogBuilder,
                      barrierDismissible: false,
                    );
                  });
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
