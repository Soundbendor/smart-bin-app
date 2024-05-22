// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/image.dart';

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
        onTap: () => onTileTap(context, detection),
        child: Card(
          // Background color of the card
          color: colorScheme.onPrimary,
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
                Container(
                    margin: const EdgeInsets.only(bottom: 12, top: 12),
                    alignment: Alignment.center,
                    child: DynamicImage(detection.postDetectImgLink!,
                        width: 325, height: 325)),
                SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Transcription:",
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

  const DetectionSmallListItem({
    super.key,
    required this.detection,
  });

  DetectionSmallListItem.stub({super.key})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
      child: GestureDetector(
        onTap: () => onTileTap(context, detection),
        child: Card(
          color: colorScheme.onPrimary,
          child: ListTile(
            leading: Container(
                child: DynamicImage(detection.postDetectImgLink!)),
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

  const DetectionList({
    super.key,
    required this.detections,
    this.size = DetectionListType.small,
    required this.loadDetections,
  });

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
                return DetectionLargeListItem(detection: detections[index]);
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
                return DetectionSmallListItem(detection: detections[index]);
              },
            ),
          ),
        );
      }
    }
  }
}
