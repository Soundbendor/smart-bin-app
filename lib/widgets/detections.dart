import 'package:flutter/material.dart';
import 'package:waste_watchers/database/models/detection.dart';
import 'package:waste_watchers/screens/main/detection_page.dart';

class DetectionListItem extends StatelessWidget {
  final Detection detection;

  const DetectionListItem({
    super.key,
    required this.detection,
  });

  DetectionListItem.stub({super.key}) : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset("assets/images/placeholder.png"),
      title: const Text("<Detection Food Names>"),
      subtitle: Text(detection.timestamp.toString()),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetectionPage(
                    detection: detection,
                  ))),
    );
  }
}

class DetectionList extends StatelessWidget {
  final List<DetectionListItem> detections;

  const DetectionList({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox(
          width: double.infinity,
          child: Text("No detections yet", textAlign: TextAlign.left));
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: detections.length,
          prototypeItem: DetectionListItem.stub(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return detections[index];
          },
        ),
      );
    }
  }
}
