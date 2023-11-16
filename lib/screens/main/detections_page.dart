import 'package:flutter/material.dart';
import 'package:waste_watchers/widgets/detections.dart';
import 'package:waste_watchers/widgets/heading.dart';

class DetectionsPage extends StatelessWidget {
  const DetectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: const Column(
          children: [
            Heading(text: "Detections"),
            DetectionList(
              detections: [
                DetectionListItem.stub(),
                DetectionListItem.stub(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
