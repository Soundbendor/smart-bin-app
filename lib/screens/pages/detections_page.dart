import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';

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
    loadDetectionFuture = Detection.all().then((value) async {
      setState(() {
        detections = value;
      });
    });
    super.initState();
  }

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
                  "Toggle Size",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
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
                        );
                })
          ],
        ),
      ),
    );
  }
}
