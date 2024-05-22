// Flutter imports:
import 'dart:io';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rotating_icon_button/rotating_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:binsight_ai/util/api.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/async_ops.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
import 'package:binsight_ai/util/providers/image_provider.dart';
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

  late Future loadDetectionFuture;

  Directory? appDocDir;

  @override
  void initState() {
    loadDetectionFuture =
        loadDetections(context, showSnackBar: false, forceRefresh: false);
    getDirectory();
    super.initState();
  }

  /// Creates and controls a dialog with its own context for the WiFi status check sequence.
  Widget wifiStatusDialogBuilder(context) {
    return const WifiCheckDialog();
  }

  Future<void> getDirectory() async {
    Directory dir = await getApplicationDocumentsDirectory();
    setState(() {
      appDocDir = dir;
    });
  }

  /// Handles reconnecting to the user's device in order to read wifi status characteristic.
  void connectToDevice(BuildContext context) async {
    // Rebuild the user's device from its id to pair and connect
    BleDevice bledevice = BleDevice.fromId(
        sharedPreferences.getString(SharedPreferencesKeys.deviceID)!);
    DeviceNotifier notifierProvider =
        Provider.of<DeviceNotifier>(context, listen: false);
    notifierProvider.setDevice(bledevice);
    await notifierProvider.connect();
    notifierProvider.listenForConnectionEvents();
    // await notifierProvider.pair();
  }

  /// Displays a dialog that asks the user if they would like to check their
  /// Wi-Fi status or not.
  Future checkWifi() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                "Check Wi-Fi Connection?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            content: Text(
                "Please unplug your bin and then plug it back in again. Wait until it says that Bluetooth has been enabled, and then click 'Yes' to check your Wi-Fi connection.",
                style: Theme.of(context).textTheme.labelLarge),
            actions: [
              TextButton(
                // Style the button to match the "sad path" color scheme
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                onPressed: () {
                  // Removes the dialog
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(250),
                      ),
                ),
              ),
              TextButton(
                // Style the button to match the "happy path" color scheme
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                onPressed: () {
                  Navigator.of(context).pop();
                  runSoon(() {
                    // Begin connecting to the device
                    connectToDevice(context);
                    // Display the wifiStatusDialogBuilder throughout the entire Wi-Fi status check process
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

  /// Function that retrieves all detections from the database.
  ///
  /// If [showSnackBar] is true, the snackBar will be rendered after the refresh.
  /// If [showSnackBar] is false, the snackBar will not be rendered after the refresh.
  /// If [forceRefresh] is true, the detections will be re-fetched from the API.
  ///
  /// Tapping the snackBar will trigger a call to [checkWifi].
  Future<void> loadDetections(
    BuildContext context, {
    bool showSnackBar = true,
    bool forceRefresh = true,
  }) async {
    // Access the detections before the refresh to compare afterwards
    final previousDetections =
        Provider.of<DetectionNotifier>(context, listen: false).detections;
    if (forceRefresh) {
      Future<DateTime> timestamp = getLatestTimestamp();
      await fetchImageData(
        sharedPreferences.getString(SharedPreferencesKeys.deviceApiID) ??
            dotenv.env['DEVICE_ID'] ??
            "",
        timestamp,
        context,
      );
    }
    return Detection.all().then((detections) async {
      // If the new detections list is larger than the old one, there are new detections
      bool areNewDetections = previousDetections.length != detections.length;
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 15),
            content: Text(
              areNewDetections
                  ? "New detections found!"
                  : "No new detections found. If you're having trouble, check your Wi-Fi connection.",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: areNewDetections
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
            action: areNewDetections
                ? SnackBarAction(
                    label: "Annotate",
                    onPressed: () => GoRouter.of(context).push(
                        "/main/detection/${Provider.of<DetectionNotifier>(context, listen: false).detections.first.imageId}"))
                : SnackBarAction(label: "Check Wi-Fi", onPressed: checkWifi),
          ),
        );
      }
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
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).colorScheme.onPrimary;
                      }
                      return Theme.of(context).colorScheme.onSurface;
                    }),
                    trackOutlineColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
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
                    : Consumer<DetectionNotifier>(
                        builder: (context, detectionNotifier, child) {
                          return Consumer<ImageNotifier>(
                            builder: (context, imageNotifier, child) {
                              return DetectionList(
                                  size: sizeToggle
                                      ? DetectionListType.large
                                      : DetectionListType.small,
                                  detections: detectionNotifier.detections,
                                  baseDir: appDocDir!,
                                  loadDetections: loadDetections);
                            },
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
