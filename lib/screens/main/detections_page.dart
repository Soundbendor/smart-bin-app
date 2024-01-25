import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void onChanged(bool value) {
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
                Switch(value: sizeToggle, onChanged: onChanged),
                const Text("Toggle Size"),
              ],
            ),
            DetectionList(
              size: sizeToggle
                  ? DetectionListType.large
                  : DetectionListType.small,
              detections: [
                Detection.createDefault(),
                Detection.createDefault(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
