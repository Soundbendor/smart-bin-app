// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:go_router/go_router.dart';

/// Displays the detections with padding and a size toggle button.
class DetectionsPage extends StatefulWidget {
  const DetectionsPage({super.key});

  @override
  State<DetectionsPage> createState() => _DetectionsPageState();
}

class _DetectionsPageState extends State<DetectionsPage> {
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

  /// Displays a dialog that asks the user if they would like to check their
  /// WiFi status or not.
  Future checkWifi() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Check WiFi Connection?"),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  // Removes the dialog
                  Navigator.of(context).pop();
                },
                child: const Text("No"),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  // Removes the dialog and takes the user back to the bluetooth setup screen
                  Navigator.of(context).pop();
                  GoRouter.of(context).pushReplacementNamed("bluetooth");
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
