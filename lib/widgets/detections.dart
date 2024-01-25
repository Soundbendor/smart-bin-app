import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/screens/main/detection_page.dart';

/// Displays a detection item in a large card format.
class DetectionLargeListItem extends StatelessWidget {
  final Detection detection;

  const DetectionLargeListItem({
    super.key,
    required this.detection,
  });

  DetectionLargeListItem.stub({super.key})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetectionPage(detection: detection)));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: [
                Text("Detection ${detection.imageId}: pending analysis...",
                    textScaler: const TextScaler.linear(1.75)),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 12, top: 12),
                    child: detection.preDetectImgLink.startsWith("http")
                        ? Image.network(detection.preDetectImgLink,
                            width: 300, height: 300)
                        : Image.asset("assets/images/placeholder.png",
                            width: 300, height: 300)),
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Temperature"),
                            Text("Humidity"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(detection.temperature.toString()),
                            Text(detection.humidity.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays a detection item in a small list format.
class DetectionSmallListItem extends StatelessWidget {
  final Detection detection;

  const DetectionSmallListItem({
    super.key,
    required this.detection,
  });

  DetectionSmallListItem.stub({super.key})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: detection.preDetectImgLink.startsWith("http")
          ? Image.network(detection.preDetectImgLink)
          : Image.asset("assets/images/placeholder.png"),
      title: Text("Detection ${detection.imageId}: pending analysis..."),
      subtitle: Text(detection.timestamp.toString()),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetectionPage(detection: detection)));
      },
    );
  }
}

/// Enum used to control the size style of the detection list items.
enum DetectionListType { large, small }

/// Displays a list of detections.
class DetectionList extends StatelessWidget {
  final List<Detection> detections;
  final DetectionListType size;

  const DetectionList({
    super.key,
    required this.detections,
    this.size = DetectionListType.small,
  });

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox(
          width: double.infinity,
          child: Text("No detections yet", textAlign: TextAlign.left));
    } else {
      if (size == DetectionListType.large) {
        return Expanded(
          child: ListView.builder(
            itemCount: detections.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return DetectionLargeListItem(detection: detections[index]);
            },
          ),
        );
      } else {
        return Expanded(
          child: ListView.builder(
            itemCount: detections.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return DetectionSmallListItem(detection: detections[index]);
            },
          ),
        );
      }
    }
  }
}
