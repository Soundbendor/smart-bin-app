import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';

class DetectionsPage extends StatelessWidget {
  const DetectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Heading(text: "Detections"),
            DetectionList(
              detections: [
                DetectionLargeListItem.stub(),
                DetectionLargeListItem.stub(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
