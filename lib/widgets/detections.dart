// Flutter imports:
import 'dart:convert';
import 'dart:io';

import 'package:binsight_ai/util/image.dart';
import 'package:binsight_ai/util/styles.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';

/// Build a title string for each detection.
///
/// If the detection has been analyzed,
/// the title will include the labels of the detected objects. If the detection
/// has not been analyzed, the title will indicate that the detection is pending.
String formatDetectionTitle(Detection detection) {
  return "Detection ${detection.imageId}";
}

/// Navigate to the detection detail page when a detection tile is tapped.
void onTileTap(BuildContext context, Detection detection) {
  GoRouter.of(context).push("/main/detection/${detection.imageId}");
}

/// Displays a detection item in a large card format.
class DetectionLargeListItem extends StatelessWidget {
  final Detection detection;
  final Directory? baseDir;

  const DetectionLargeListItem({
    super.key,
    required this.detection,
    required this.baseDir,
  });

  DetectionLargeListItem.stub({super.key, this.baseDir})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    File? image = baseDir != null
        ? getImage(detection.postDetectImgLink!, baseDir)
        : null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => onTileTap(context, detection),
        child: Card(
          // Background color of the card
          color: ((jsonDecode(detection.boxes ?? "[]") as List).isNotEmpty) ? colorScheme.tertiary : colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(11.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDetectionTitle(detection),
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Timestamp: ${detection.timestamp}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Center(
                  child: Container(
                    width: 325,
                    margin: const EdgeInsets.only(bottom: 12, top: 12),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        image != null
                            ? Image.file(
                                image,
                                width: 325,
                              )
                            : Container(),
                        if (jsonDecode(detection.boxes ?? "[]").isNotEmpty)
                          Icon(Icons.bookmark_added,
                              color: mainColorScheme.tertiary),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Transcription: ",
                                style: textTheme.titleMedium),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(detection.transcription.toString(),
                                style: textTheme.labelMedium),
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
  final Directory? baseDir;

  const DetectionSmallListItem({
    super.key,
    required this.detection,
    required this.baseDir,
  });

  DetectionSmallListItem.stub({super.key, this.baseDir})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    File? image = baseDir != null
        ? getImage(detection.postDetectImgLink!, baseDir)
        : null;

    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
      child: GestureDetector(
        onTap: () => onTileTap(context, detection),
        child: Card(
          color: ((jsonDecode(detection.boxes ?? "[]") as List).isNotEmpty) ? mainColorScheme.tertiary : colorScheme.onPrimary,
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.onSurface,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  image != null ? Image.file(image) : Container(),
                  if ((jsonDecode(detection.boxes ?? "[]") as List).isNotEmpty)
                    Icon(Icons.bookmark_added, color: mainColorScheme.tertiary),
                ],
              ),
            ),
            title: Text(formatDetectionTitle(detection),
                style: textTheme.titleMedium),
            subtitle: Text(detection.timestamp.toString(),
                style: textTheme.bodyMedium),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}

/// Enum used to control the size style of the detection list items.
enum DetectionListType { large, small }

/// Displays a list of detections.
class DetectionList extends StatelessWidget {
  final List<Detection> detections;
  final DetectionListType size;
  final Function loadDetections;
  final Directory baseDir;

  const DetectionList(
      {super.key,
      required this.detections,
      this.size = DetectionListType.small,
      required this.loadDetections,
      required this.baseDir});

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return SizedBox(
          width: double.infinity,
          child: Text(
              "Ooops! \n"
              "No images detected yet. \n"
              "Please swipe down to reload.",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center));
    } else {
      if (size == DetectionListType.large) {
        return Expanded(
          child: RefreshIndicator(
            onRefresh: () => loadDetections(context),
            child: ListView.builder(
              itemCount: detections.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return DetectionLargeListItem(
                  detection: detections[index],
                  baseDir: baseDir,
                );
              },
            ),
          ),
        );
      } else {
        return Expanded(
          child: RefreshIndicator(
            onRefresh: () => loadDetections(context),
            child: ListView.builder(
              itemCount: detections.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return DetectionSmallListItem(
                  detection: detections[index],
                  baseDir: baseDir,
                );
              },
            ),
          ),
        );
      }
    }
  }
}
