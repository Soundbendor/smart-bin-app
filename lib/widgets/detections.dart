import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:go_router/go_router.dart';

String formatDetectionTitle(Detection detection) {
  if (detection.boxes != null) {
    final boxData = jsonDecode(detection.boxes!);
    final List<String> keys = [];
    for (final box in boxData) {
      keys.add(box.keys.first);
    }
    return "Detection ${detection.imageId}: ${keys.join(", ")}";
  } else {
    return "Detection ${detection.imageId}: pending analysis...";
  }
}

void _onTileTap(BuildContext context, Detection detection) {
  context.go("/main/detection/${detection.imageId}");
}

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _onTileTap(context, detection),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: [
                Text(formatDetectionTitle(detection),
                    style: textTheme.headlineSmall),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Temperature", style: textTheme.labelLarge),
                            Text("Humidity", style: textTheme.labelLarge),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(detection.temperature.toString(),
                                style: textTheme.bodyMedium),
                            Text(detection.humidity.toString(),
                                style: textTheme.bodyMedium),
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
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: detection.preDetectImgLink.startsWith("http")
          ? Image.network(detection.preDetectImgLink)
          : Image.asset("assets/images/placeholder.png"),
      title:
          Text(formatDetectionTitle(detection), style: textTheme.titleMedium),
      subtitle:
          Text(detection.timestamp.toString(), style: textTheme.bodyMedium),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _onTileTap(context, detection),
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
