// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/image.dart';

/// Displays information about a single detection.
class DetectionPage extends StatelessWidget {
  final Future<Detection?> detectionFuture;

  DetectionPage({super.key, required Detection detection})
      : detectionFuture = Future.value(detection);
  DetectionPage.fromId({super.key, required String detectionId})
      : detectionFuture = Detection.find(detectionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _BackToListButton(),
              const SizedBox(height: 16),
              _DetectionHeader(detectionFuture: detectionFuture),
              const SizedBox(height: 16),
              FutureBuilder(
                future: detectionFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final detection = snapshot.data!;
                    return _DetectionCard(detection: detection);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// The card that displays the detection information, including the image and sensor data.
class _DetectionCard extends StatelessWidget {
  final Detection detection;
  const _DetectionCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          children: [
            SizedBox(
              width: 350,
              height: 350,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 1,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: DynamicImage(
                      detection.preDetectImgLink,
                      width: 350,
                      height: 350,
                    ),
                  ),
                  // Annotate Image Button
                  Positioned(
                    bottom: 16,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 30,
                      tooltip: "Annotate Image",
                      onPressed: () {
                        GoRouter.of(context).push(
                            "/main/detection/${detection.imageId}/annotation");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(200),
                        ),
                        shape: MaterialStateProperty.all(const CircleBorder()),
                      ),
                      color: Theme.of(context).colorScheme.onPrimary,
                      splashColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataField("Transcription", detection.transcription.toString(), textTheme),
                _buildDataField("Temperature", detection.temperature.toString(), textTheme),
                _buildDataField("Weight", detection.weight.toString(), textTheme),
                _buildDataField("Total Weight", detection.totalWeight.toString(), textTheme),
                _buildDataField("Humidity", detection.humidity.toString(), textTheme),
                _buildDataField("CO2 Equivalent", detection.co2.toString(), textTheme),
                _buildDataField("Pressure", detection.pressure.toString(), textTheme),
                _buildDataField("Indoor Air Quality", detection.iaq.toString(), textTheme),
                _buildDataField("Total Volatile Organic Compounds", detection.vo2.toString(), textTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Creates a row with a title and a value to build the sensor data fields.
  Widget _buildDataField(String title, String value, TextTheme textTheme) {
    return Row(
      children: [
        Text(title, style: textTheme.labelLarge),
        const SizedBox(width: 10),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }
}

/// The header for the detection page, which displays the title and timestamp.
class _DetectionHeader extends StatelessWidget {
  const _DetectionHeader({
    required this.detectionFuture,
  });

  final Future<Detection?> detectionFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: detectionFuture,
        builder: (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Heading(text: "Loading...");
          } else {
            final detection = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(text: formatDetectionTitle(detection)),
                Text(
                  "Timestamp: ${detection.timestamp}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }
        });
  }
}

/// A button that navigates back to the list of detections.
class _BackToListButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios),
          Text("Back to list", style: textTheme.labelLarge),
        ],
      ),
      onTap: () => GoRouter.of(context).pop(),
    );
  }
}
