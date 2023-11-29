import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';

class DetectionsPage extends StatefulWidget {
  const DetectionsPage({super.key});

  @override
  State<DetectionsPage> createState() => _DetectionsPageState();
}

class _DetectionsPageState extends State<DetectionsPage> {

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
              size: sizeToggle ? DetectionListType.large : DetectionListType.small,
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
